# modules/monitoring/cloudwatch_config.tf
resource "aws_cloudwatch_log_group" "trading" {
  name              = "/aws/${var.project}/${var.environment}/trading"
  retention_in_days = var.retention_days

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "audit" {
  name              = "/aws/${var.project}/${var.environment}/audit"
  retention_in_days = var.retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = local.tags
}

resource "aws_kms_key" "logs" {
  description             = "KMS key for log encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.tags
}

# Log Metric Filters
resource "aws_cloudwatch_log_metric_filter" "order_failures" {
  name           = "order-failures"
  pattern        = "[timestamp, requestId, level = ERROR, message = *OrderFailure*]"
  log_group_name = aws_cloudwatch_log_group.trading.name

  metric_transformation {
    name          = "OrderFailures"
    namespace     = "Trading/Orders"
    value         = "1"
    default_value = "0"
  }
}
