# modules/monitoring/trading_metrics.tf
resource "aws_cloudwatch_metric_stream" "trading" {
  name         = "${local.name}-metrics"
  firehose_arn = aws_kinesis_firehose_delivery_stream.metrics.arn
  role_arn     = aws_iam_role.metric_stream.arn

  include_filter {
    namespace = "Trading/Orders"
  }

  include_filter {
    namespace = "Trading/MarketData"
  }

  include_filter {
    namespace = "Trading/Execution"
  }
}

# Trading Dashboard
resource "aws_cloudwatch_dashboard" "trading" {
  dashboard_name = "${local.name}-trading"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["Trading/Orders", "OrderLatency", "Service", "Arbiters"],
            ["Trading/Orders", "OrderThroughput", "Service", "Arbiters"]
          ]
          period = 60
          stat   = "Average"
          region = var.region
          title  = "Order Processing"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["Trading/MarketData", "DataLatency"],
            ["Trading/MarketData", "UpdateRate"]
          ]
          period = 60
          stat   = "Average"
          region = var.region
          title  = "Market Data"
        }
      }
    ]
  })
}

# modules/monitoring/trading_metrics_enhanced.tf
resource "aws_cloudwatch_dashboard" "trading_performance" {
  dashboard_name = "${local.name}-trading-performance"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["Trading/Performance", "OrderProcessingTime", "Type", "Market"],
            ["Trading/Performance", "OrderProcessingTime", "Type", "Limit"],
            ["Trading/Performance", "OrderProcessingTime", "Type", "Stop"]
          ]
          period = 60
          stat   = "p95"
          region = var.region
          title  = "Order Processing Latency (p95)"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["Trading/MarketData", "QuoteDelay"],
            ["Trading/MarketData", "TradeDelay"]
          ]
          period = 60
          stat   = "Average"
          region = var.region
          title  = "Market Data Latency"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["Trading/System", "MemoryUtilization"],
            ["Trading/System", "CPUUtilization"]
          ]
          period = 60
          stat   = "Maximum"
          region = var.region
          title  = "System Resources"
        }
      }
    ]
  })
}

# Additional trading-specific alarms
resource "aws_cloudwatch_metric_alarm" "execution_failures" {
  alarm_name          = "${local.name}-execution-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ExecutionFailures"
  namespace           = "Trading/Execution"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "High number of trade execution failures"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    Environment = var.environment
  }
}
