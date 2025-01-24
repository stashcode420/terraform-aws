# modules/eks/security_groups.tf

# Cluster Security Group
resource "aws_security_group" "cluster" {
  name_prefix = "${local.name}-cluster"
  description = "EKS cluster security group"
  vpc_id      = data.aws_vpc.existing.id

  timeouts {
    delete = "20m"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.tags, {
    "kubernetes.io/cluster/${local.name}" = "owned"
    "Name"                                = "${local.name}-cluster"
  })
}

resource "aws_security_group" "node" {
  name_prefix = "${local.name}-node"
  description = "Security group for EKS node groups"
  vpc_id      = data.aws_vpc.existing.id

  tags = merge(
    local.tags,
    {
      "kubernetes.io/cluster/${aws_eks_cluster.main.name}" = "owned"
    }
  )
}


# Cluster Security Group Rules
resource "aws_security_group_rule" "cluster_ingress_nodes_https" {
  description              = "Allow nodes to communicate with the cluster API Server"
  protocol                = "tcp"
  security_group_id       = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.nodes.id
  from_port               = 443
  to_port                 = 443
  type                    = "ingress"
}

resource "aws_security_group_rule" "cluster_egress" {
  description       = "Allow cluster egress access"
  protocol         = "-1"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks      = ["0.0.0.0/0"]
  from_port        = 0
  to_port          = 0
  type             = "egress"
  
  timeouts {
    create = "15m"
  }
}

resource "aws_security_group_rule" "node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node_egress_internet" {
  description       = "Allow nodes to communicate with the Internet"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.node.id
  cidr_blocks       = ["0.0.0.0/0"]
  to_port           = 0
  type              = "egress"
}

# Cleanup Helper
resource "null_resource" "cluster_sg_cleanup" {
  triggers = {
    security_group_id = aws_security_group.cluster.id
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      $MaxAttempts = 30
      $Attempt = 0
      $SG_ID = "${self.triggers.security_group_id}"
      
      Do {
        $Attempt++
        Write-Host "Attempt $Attempt to cleanup security group $SG_ID"
        
        try {
          # Get all dependent resources
          $Dependencies = aws ec2 describe-security-group-references --group-id $SG_ID
          
          if ($Dependencies) {
            Write-Host "Found dependencies, attempting to remove..."
          }
          
          # Remove all inbound rules
          aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$SG_ID" --query 'SecurityGroupRules[?IsEgress==`false`].SecurityGroupRuleId' --output text | 
          ForEach-Object {
            if ($_) {
              aws ec2 revoke-security-group-ingress --group-id $SG_ID --security-group-rule-ids $_
            }
          }
          
          # Remove all outbound rules
          aws ec2 describe-security-group-rules --filters "Name=group-id,Values=$SG_ID" --query 'SecurityGroupRules[?IsEgress==`true`].SecurityGroupRuleId' --output text | 
          ForEach-Object {
            if ($_) {
              aws ec2 revoke-security-group-egress --group-id $SG_ID --security-group-rule-ids $_
            }
          }
          
          Break
        }
        catch {
          if ($Attempt -eq $MaxAttempts) {
            Write-Error "Failed to cleanup security group after $MaxAttempts attempts"
            Exit 1
          }
          Write-Host "Attempt failed, waiting 30 seconds before retry..."
          Start-Sleep -Seconds 30
        }
      } While ($Attempt -lt $MaxAttempts)
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}

# Dependency Checker
resource "null_resource" "verify_no_dependencies" {
  triggers = {
    cluster_sg_id = aws_security_group.cluster.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      $SG_ID = "${aws_security_group.cluster.id}"
      $Dependencies = aws ec2 describe-security-group-references --group-id $SG_ID
      
      if ($Dependencies) {
        Write-Host "Warning: Security group has dependencies that might prevent deletion"
        $Dependencies | ConvertTo-Json
      }
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}