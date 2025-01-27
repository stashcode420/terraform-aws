# modules/database/main.tf

locals {
  name = "${var.project}-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name        = "${local.name}-db-subnet"
  description = "Database subnet group for ${local.name}"
  subnet_ids  = var.private_subnet_ids

  tags = local.tags
}

# Monitoring IAM Role
resource "aws_iam_role" "monitoring" {
  name = "${local.name}-db-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

# Backup IAM Role
resource "aws_iam_role" "backup" {
  name = "${local.name}-db-backup"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup.name
}

# CloudWatch Log Group for Database Logs
resource "aws_cloudwatch_log_group" "database" {
  name              = "/aws/rds/${local.name}"
  retention_in_days = var.log_retention_days

  tags = local.tags
}

# Event Subscription for Database Events
resource "aws_db_event_subscription" "database" {
  name      = "${local.name}-db-events"
  sns_topic = var.sns_topic_arn

  source_type = "db-instance"
  source_ids  = [aws_db_instance.application.id]

  event_categories = [
    "availability",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "maintenance",
    "notification",
    "recovery",
    "restoration"
  ]

  tags = local.tags
}
