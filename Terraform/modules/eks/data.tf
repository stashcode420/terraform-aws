# modules/eks/data.tf

data "aws_region" "current" {}

# EKS Cluster data sources - these are correctly defined but depend on the cluster
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.main.name
  depends_on = [aws_eks_cluster.main]
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.main.name
  depends_on = [aws_eks_cluster.main]
}

# TLS certificate for OIDC provider
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
  depends_on = [aws_eks_cluster.main]
}

# VPC and Subnet data sources
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["${var.project}-${var.environment}-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.project}-${var.environment}-vpc-private-*"]
  }

  depends_on = [data.aws_vpc.existing]
}

# Get private route tables
data "aws_route_tables" "private" {
  vpc_id = data.aws_vpc.existing.id

  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }

  depends_on = [data.aws_vpc.existing]
}

# Add this to validate subnet configuration
data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

