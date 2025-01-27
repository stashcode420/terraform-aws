# modules/monitoring/opensearch.tf

# OpenSearch Domain
resource "aws_opensearch_domain" "logs" {
  domain_name    = "${local.name}-logs"
  engine_version = "OpenSearch_2.5"

  cluster_config {
    instance_type = var.environment == "prod" ? "r6g.2xlarge.search" : "r6g.large.search"

    instance_count = var.environment == "prod" ? 3 : 1

    zone_awareness_enabled = var.environment == "prod" ? true : false

    dynamic "zone_awareness_config" {
      for_each = var.environment == "prod" ? [1] : []
      content {
        availability_zone_count = 3
      }
    }

    dedicated_master_enabled = var.environment == "prod" ? true : false
    dedicated_master_count   = var.environment == "prod" ? 3 : 0
    dedicated_master_type    = var.environment == "prod" ? "r6g.large.search" : null
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.environment == "prod" ? 100 : 20
    volume_type = "gp3"
  }

  vpc_options {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.opensearch.id]
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = aws_kms_key.opensearch.arn
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = false
    master_user_options {
      master_user_arn = aws_iam_role.opensearch_master.arn
    }
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "ES_APPLICATION_LOGS"
    enabled                  = true
  }

  auto_tune_options {
    desired_state = "ENABLED"
    maintenance_schedule {
      start_at                       = timeadd(timestamp(), "24h")
      duration                       = "2h"
      cron_expression_for_recurrence = "cron(0 0 ? * SUN *)"
    }
  }

  tags = local.tags
}

# Security Group for OpenSearch
resource "aws_security_group" "opensearch" {
  name        = "${local.name}-opensearch"
  description = "Security group for OpenSearch domain"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.eks_cluster_security_group_id]
    description     = "Allow HTTPS from EKS cluster"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(local.tags, {
    Name = "${local.name}-opensearch"
  })
}

# KMS Key for OpenSearch encryption
resource "aws_kms_key" "opensearch" {
  description             = "KMS key for OpenSearch encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow OpenSearch to use the key"
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.tags
}

# CloudWatch Log Group for OpenSearch logs
resource "aws_cloudwatch_log_group" "opensearch_logs" {
  name              = "/aws/opensearch/${local.name}"
  retention_in_days = var.log_retention_days

  tags = local.tags
}

# IAM Role for OpenSearch master user
resource "aws_iam_role" "opensearch_master" {
  name = "${local.name}-opensearch-master"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

# OpenSearch Index Template
resource "null_resource" "index_template" {
  depends_on = [aws_opensearch_domain.logs]

  provisioner "local-exec" {
    command = <<EOF
curl -X PUT "${aws_opensearch_domain.logs.endpoint}/_template/logging_template" \
  -H 'Content-Type: application/json' \
  -d '{
    "index_patterns": ["logs-*"],
    "settings": {
      "number_of_shards": 3,
      "number_of_replicas": 1,
      "index.lifecycle.name": "logs_policy",
      "index.lifecycle.rollover_alias": "logs"
    },
    "mappings": {
      "properties": {
        "timestamp": { "type": "date" },
        "level": { "type": "keyword" },
        "service": { "type": "keyword" },
        "message": { "type": "text" },
        "trace_id": { "type": "keyword" },
        "order_id": { "type": "keyword" },
        "latency": { "type": "float" }
      }
    }
  }'
EOF
  }
}

# OpenSearch ILM Policy
resource "null_resource" "ilm_policy" {
  depends_on = [aws_opensearch_domain.logs]

  provisioner "local-exec" {
    command = <<EOF
curl -X PUT "${aws_opensearch_domain.logs.endpoint}/_ilm/policy/logs_policy" \
  -H 'Content-Type: application/json' \
  -d '{
    "policy": {
      "phases": {
        "hot": {
          "actions": {
            "rollover": {
              "max_size": "50GB",
              "max_age": "1d"
            }
          }
        },
        "warm": {
          "min_age": "2d",
          "actions": {
            "shrink": {
              "number_of_shards": 1
            },
            "forcemerge": {
              "max_num_segments": 1
            }
          }
        },
        "cold": {
          "min_age": "7d",
          "actions": {
            "readonly": {}
          }
        },
        "delete": {
          "min_age": "30d",
          "actions": {
            "delete": {}
          }
        }
      }
    }
  }'
EOF
  }
}
