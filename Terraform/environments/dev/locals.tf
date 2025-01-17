# locals.tf
locals {
  name_prefix = "trading-${var.environment}"

  common_tags = {
    Environment = var.environment
    Project     = "trading-platform"
    ManagedBy   = "terraform"
  }

  eks_node_groups = {
    general = {
      name          = "general"
      instance_type = "t3.large"
      min_size      = 1
      max_size      = 3
      desired_size  = 2
    }
  }

  vpc_endpoints = {
    s3       = true
    dynamodb = true
    ecr_api  = true
    ecr_dkr  = true
    logs     = true
  }
}
