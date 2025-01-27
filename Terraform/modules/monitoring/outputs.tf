# modules/monitoring/outputs.tf
output "prometheus_endpoint" {
  description = "Prometheus workspace endpoint"
  value       = aws_prometheus_workspace.main.prometheus_endpoint
}

output "grafana_endpoint" {
  description = "Grafana workspace endpoint"
  value       = aws_grafana_workspace.main.endpoint
}

output "opensearch_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = aws_opensearch_domain.main.endpoint
}

output "log_group_names" {
  description = "CloudWatch Log Group names"
  value = {
    trading = aws_cloudwatch_log_group.trading.name
    audit   = aws_cloudwatch_log_group.audit.name
  }
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}
