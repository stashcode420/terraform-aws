# # modules/eks/trading_monitoring.tf

# resource "aws_cloudwatch_metric_alarm" "arbiter_latency" {
#   alarm_name          = "${local.name}-arbiter-high-latency"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "OrderProcessingLatency"
#   namespace           = "Trading/Arbiters"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = "100" # 100ms threshold
#   alarm_description   = "Trading order processing latency is high"
#   alarm_actions       = [var.sns_topic_arn]

#   dimensions = {
#     ClusterName = aws_eks_cluster.main.name
#     NodeGroup   = "arbiters"
#   }
# }

# resource "aws_cloudwatch_dashboard" "trading" {
#   dashboard_name = "${local.name}-trading-metrics"

#   dashboard_body = jsonencode({
#     widgets = [
#       {
#         type = "metric"
#         properties = {
#           metrics = [
#             ["Trading/Arbiters", "OrderProcessingLatency"],
#             ["Trading/MarketData", "DataProcessingLatency"],
#             ["Trading/Executors", "OrderExecutionLatency"]
#           ]
#           period = 60
#           region = var.region
#           title  = "Trading Latencies"
#         }
#       },
#       {
#         type = "metric"
#         properties = {
#           metrics = [
#             ["Trading/Arbiters", "OrdersPerSecond"],
#             ["Trading/MarketData", "UpdatesPerSecond"],
#             ["Trading/Executors", "ExecutionsPerSecond"]
#           ]
#           period = 60
#           region = var.region
#           title  = "Trading Throughput"
#         }
#       }
#     ]
#   })
# }
