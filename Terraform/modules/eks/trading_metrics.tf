# modules/eks/trading_metrics.tf

resource "aws_cloudwatch_metric_alarm" "order_failure_rate" {
  alarm_name          = "${local.name}-order-failure-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "OrderFailureRate"
  namespace           = "Trading/Executors"
  period              = "300"
  statistic           = "Average"
  threshold           = "5" # 5% failure rate threshold
  alarm_description   = "Order failure rate is above threshold"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    Service     = "Executors"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "market_data_delay" {
  alarm_name          = "${local.name}-market-data-delay"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MarketDataDelay"
  namespace           = "Trading/MarketData"
  period              = "60"
  statistic           = "Average"
  threshold           = "200" # 200ms delay threshold
  alarm_description   = "Market data processing delay is high"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    Service     = "MarketData"
    Environment = var.environment
  }
}
