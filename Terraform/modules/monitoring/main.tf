# modules/monitoring/main.tf
locals {
  name = "${var.project}-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}

# Prometheus workspace for EKS monitoring
resource "aws_prometheus_workspace" "main" {
  alias = local.name

  tags = local.tags
}

# OpenSearch Domain for log aggregation
resource "aws_opensearch_domain" "main" {
  domain_name    = "${local.name}-logs"
  engine_version = "OpenSearch_2.5"

  cluster_config {
    instance_type          = "r6g.large.search"
    instance_count         = 3
    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = 3
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 100
  }

  vpc_options {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.opensearch.id]
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  tags = local.tags
}
