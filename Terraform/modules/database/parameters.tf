# modules/database/backup.tf
resource "aws_db_snapshot" "application" {
  db_instance_identifier = aws_db_instance.application.id
  db_snapshot_identifier = "${local.name}-snapshot-${formatdate("YYYY-MM-DD-hh-mm", timestamp())}"

  tags = local.tags
}

resource "aws_backup_plan" "database" {
  name = "${local.name}-backup-plan"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.database.name
    schedule          = "cron(0 5 ? * * *)" # Daily at 5 AM

    lifecycle {
      delete_after = var.backup_retention_period
    }
  }

  rule {
    rule_name         = "weekly_backup"
    target_vault_name = aws_backup_vault.database.name
    schedule          = "cron(0 5 ? * 1 *)" # Weekly on Sunday at 5 AM

    lifecycle {
      delete_after = 30
    }
  }

  tags = local.tags
}

resource "aws_backup_vault" "database" {
  name        = "${local.name}-backup-vault"
  kms_key_arn = var.kms_key_arn

  tags = local.tags
}

resource "aws_backup_selection" "database" {
  name         = "${local.name}-backup-selection"
  plan_id      = aws_backup_plan.database.id
  iam_role_arn = aws_iam_role.backup.arn

  resources = [
    aws_db_instance.application.arn
  ]
}
