# modules/monitoring/prometheus.tf
resource "aws_prometheus_alert_manager_definition" "trading" {
  workspace_id = aws_prometheus_workspace.main.id

  definition = <<EOF
alertmanager_config: |
  route:
    receiver: 'sns'
    group_by: ['alertname', 'severity']
    group_wait: 30s
    group_interval: 5m
    repeat_interval: 4h
    routes:
      - match:
          severity: critical
        receiver: 'pager'
        group_wait: 10s
  receivers:
    - name: 'sns'
      sns_configs:
        - topic_arn: ${aws_sns_topic.alerts.arn}
    - name: 'pager'
      pagerduty_configs:
        - service_key: ${var.pagerduty_service_key}
EOF
}

resource "aws_prometheus_rule_group_namespace" "trading" {
  name         = "trading"
  workspace_id = aws_prometheus_workspace.main.id

  data = <<EOF
groups:
  - name: trading
    rules:
      - alert: HighOrderLatency
        expr: histogram_quantile(0.95, rate(order_processing_duration_seconds_bucket[5m])) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: High order processing latency
          description: 95th percentile of order processing latency is above 100ms

      - alert: MarketDataDelay
        expr: market_data_delay_seconds > 0.5
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: Market data delay detected
          description: Market data processing delay is above 500ms
EOF
}
