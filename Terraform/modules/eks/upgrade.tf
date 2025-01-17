# modules/eks/upgrade.tf

resource "null_resource" "upgrade_cluster" {
  triggers = {
    cluster_version = var.eks_version
  }

  provisioner "local-exec" {
    command = <<-EOF
      aws eks update-cluster-version \
        --region ${var.region} \
        --name ${aws_eks_cluster.main.name} \
        --kubernetes-version ${var.eks_version}
    EOF
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_function" "node_drainer" {
  filename      = "${path.module}/functions/node-drainer.zip"
  function_name = "${local.name}-node-drainer"
  role          = aws_iam_role.node_drainer.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"

  environment {
    variables = {
      CLUSTER_NAME = aws_eks_cluster.main.name
    }
  }
}
