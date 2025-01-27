# modules/eks/main.tf

locals {
  name = "${var.project}-${var.environment}"
  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  })
}

resource "aws_eks_cluster" "main" {
  name     = local.name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = data.aws_subnets.private.ids
    endpoint_private_access = true
    endpoint_public_access  = var.enable_public_access
    # public_access_cidrs    = var.public_access_cidrs
    security_group_ids      = [aws_security_group.cluster.id]
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policies
  ]

  tags = local.tags
}

# KMS Key for EKS
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                 = data.aws_iam_policy_document.kms.json

  tags = local.tags
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${local.name}-eks"
  target_key_id = aws_kms_key.eks.key_id
}

# resource "aws_cloudwatch_log_group" "eks" {
#   name              = "/aws/eks/${local.name}/cluster"
#   retention_in_days = var.log_retention_days
#   kms_key_id       = data.aws_kms_key.cloudwatch.arn

#   tags = local.tags

#   lifecycle {
#     prevent_destroy = true
#     ignore_changes = [
#       name,
#       retention_in_days
#     ]
#   }
# }

# OIDC Provider
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = local.tags
}

# Data sources
data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow EKS to use the key"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "eks.amazonaws.com"
      ]
    }
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
  }
}

data "aws_caller_identity" "current" {}

# data "tls_certificate" "eks" {
#   url = aws_eks_cluster.main.identity[0].oidc[0].issuer
# }