# modules/monitoring/alerts.tf
resource "aws_cloudwatch_metric_alarm" "order_latency" {
  alarm_name          = "${local.name}-high-order-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "OrderLatency"
  namespace           = "Trading/Orders"
  period              = "60"
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "Order processing latency is too high"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "market_data_delay" {
  alarm_name          = "${local.name}-market-data-delay"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DataDelay"
  namespace           = "Trading/MarketData"
  period              = "60"
  statistic           = "Average"
  threshold           = "500"
  alarm_description   = "Market data delay is too high"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_sns_topic" "alerts" {
  name = "${local.name}-alerts"

  kms_master_key_id = aws_kms_key.sns.id

  tags = local.tags
}
