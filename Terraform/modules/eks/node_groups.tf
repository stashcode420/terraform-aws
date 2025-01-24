# modules/eks/node_groups.tf

locals {
  default_node_groups = {
    system = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size      = 2
      max_size      = 4
      disk_size     = 50
      labels = {
        "node-type" = "system"
      }
      taints = []
    }
  }

  node_groups = merge(local.default_node_groups, var.node_groups)
}

# Get the latest EKS-optimized AMI
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.main.version}/amazon-linux-2023/x86_64/standard/recommended/release_version"
}

# modules/eks/node_groups.tf

resource "aws_launch_template" "node" {
  for_each = var.node_groups

  name_prefix = "${local.name}-${each.key}-"
  description = "EKS node group launch template"

  vpc_security_group_ids = [aws_security_group.node.id]

  # Add key pair
  key_name = aws_key_pair.node.key_name

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = lookup(each.value, "disk_size", 50)
      volume_type          = "gp3"
      delete_on_termination = true
      encrypted            = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh.tpl", {
    cluster_name         = aws_eks_cluster.main.name
    cluster_endpoint     = aws_eks_cluster.main.endpoint
    cluster_ca_data      = aws_eks_cluster.main.certificate_authority[0].data
    cluster_dns_ip       = "172.20.0.10"
    node_labels         = join(",", [for k, v in lookup(each.value, "labels", {}) : "${k}=${v}"])
    node_taints         = join(",", lookup(each.value, "taints", []))
    bootstrap_extra_args = lookup(each.value, "bootstrap_extra_args", "")
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.tags,
      {
        "Name" = "${local.name}-${each.key}"
        "kubernetes.io/cluster/${aws_eks_cluster.main.name}" = "owned"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.name}-${each.key}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = data.aws_subnets.private.ids

  instance_types = lookup(each.value, "instance_types", ["t3.medium"])
  capacity_type  = lookup(each.value, "capacity_type", "ON_DEMAND")
  
  # Use the latest EKS-optimized AMI
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  launch_template {
    id      = aws_launch_template.node[each.key].id
    version = aws_launch_template.node[each.key].latest_version
  }

  scaling_config {
    desired_size = lookup(each.value, "desired_size", 2)
    max_size     = lookup(each.value, "max_size", 4)
    min_size     = lookup(each.value, "min_size", 1)
  }

  update_config {
    max_unavailable = 1
  }

  # Add node repair configuration
  node_repair_config {
    enabled = true  # Enable auto-repair for the node group
  }

  # Add taints if specified
  dynamic "taint" {
    for_each = lookup(each.value, "taints", [])
    content {
      key    = taint.value.key
      value  = lookup(taint.value, "value", null)
      effect = taint.value.effect
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policies,
    aws_vpc_endpoint.eks,
    aws_vpc_endpoint.ecr_dkr,
    aws_vpc_endpoint.ecr_api,
    aws_vpc_endpoint.s3
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = merge(
    local.tags,
    {
      "k8s.io/cluster-autoscaler/enabled"                  = "true"
      "k8s.io/cluster-autoscaler/${aws_eks_cluster.main.name}" = "owned"
    }
  )
}