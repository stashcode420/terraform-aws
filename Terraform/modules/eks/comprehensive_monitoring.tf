# modules/eks/comprehensive_monitoring.tf

resource "aws_cloudwatch_dashboard" "eks_comprehensive" {
  dashboard_name = "${local.name}-comprehensive"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["ContainerInsights", "node_cpu_utilization"],
            ["ContainerInsights", "node_memory_utilization"],
            ["ContainerInsights", "node_network_total_bytes"],
            ["ContainerInsights", "pod_cpu_utilization"]
          ]
          period = 300
          region = var.region
          title  = "Node and Pod Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["Trading/Performance", "OrderLatency"],
            ["Trading/Performance", "MarketDataLatency"],
            ["Trading/Performance", "ExecutionLatency"]
          ]
          period = 60
          region = var.region
          title  = "Trading Performance"
        }
      },
      {
        type = "log"
        properties = {
          query  = "fields @timestamp, @message | filter @message like /Error/"
          region = var.region
          title  = "Error Logs"
          view   = "table"
        }
      }
    ]
  })
}
