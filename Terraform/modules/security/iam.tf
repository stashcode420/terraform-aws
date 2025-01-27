# modules/security/iam.tf
# EKS Cluster Role
resource "aws_iam_role" "eks_cluster" {
  name = "${local.name}-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = local.tags
}

# Trading Services Role
resource "aws_iam_role" "trading_services" {
  name = "${local.name}-trading-services"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = local.tags
}

# Trading Services Policy
resource "aws_iam_role_policy" "trading_services" {
  name = "trading-services-policy"
  role = aws_iam_role.trading_services.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_kms_key.trading.arn,
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:trading/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = [
          "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${local.name}-trading-*"
        ]
      }
    ]
  })
}
