# modules/database/rds.tf
resource "aws_db_instance" "application" {
  identifier = "${local.name}-app"

  engine            = "postgres"
  engine_version    = "14.7"
  instance_class    = var.instance_class
  allocated_storage = 100
  storage_type      = "gp3"
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  db_name  = "trading_app"
  username = "admin"
  password = random_password.db_password.result
  port     = 5432

  multi_az               = var.multi_az
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id       = var.kms_key_arn

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  auto_minor_version_upgrade = true
  deletion_protection        = true

  # Parameter group
  parameter_group_name = aws_db_parameter_group.application.name

  tags = local.tags
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name       = "${local.name}/db-credentials"
  kms_key_id = var.kms_key_arn
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = aws_db_instance.application.username
    password = random_password.db_password.result
    host     = aws_db_instance.application.endpoint
    port     = aws_db_instance.application.port
    dbname   = aws_db_instance.application.db_name
  })
}
