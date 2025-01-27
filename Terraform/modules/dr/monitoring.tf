# modules/dr/monitoring.tf
# CloudWatch Dashboard for DR metrics
resource "aws_cloudwatch_dashboard" "dr" {
  dashboard_name = "${local.name_prefix}-dr-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Route53", "HealthCheckStatus", "HealthCheckId", aws_route53_health_check.primary.id]
          ]
          period = 60
          region = var.primary_region
          title  = "Primary Health Check Status"
        }
      }
    ]
  })
}
