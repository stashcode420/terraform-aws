# modules/security/main.tf
locals {
  name = "${var.project}-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }

  common_tags = merge(var.tags, local.tags)
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
