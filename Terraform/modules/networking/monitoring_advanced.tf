# infrastructure/modules/networking/monitoring_advanced.tf

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "networking" {
  dashboard_name = "${local.name}-network-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/NetworkELB", "HealthyHostCount"],
            ["AWS/NetworkELB", "UnHealthyHostCount"],
            ["AWS/NetworkELB", "ActiveFlowCount"],
            ["AWS/NetworkELB", "ProcessedBytes"]
          ]
          period = 300
          region = var.region
          title  = "NLB Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/TransitGateway", "BytesIn"],
            ["AWS/TransitGateway", "BytesOut"],
            ["AWS/TransitGateway", "PacketsIn"],
            ["AWS/TransitGateway", "PacketsOut"]
          ]
          period = 300
          region = var.region
          title  = "Transit Gateway Metrics"
        }
      }
    ]
  })
}

# Network Performance Alarms
resource "aws_cloudwatch_metric_alarm" "network_latency" {
  alarm_name          = "${local.name}-network-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "NetworkLatency"
  namespace           = "AWS/NetworkELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Network latency is too high"
  alarm_actions       = [aws_sns_topic.network_alerts.arn]
}

# infrastructure/modules/networking/advanced_monitoring.tf

# Advanced Network Monitoring Dashboard
resource "aws_cloudwatch_dashboard" "network_advanced" {
  dashboard_name = "${local.name}-network-advanced"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/NetworkELB", "ProcessedBytes", "LoadBalancer", "*"],
            ["AWS/NetworkELB", "ActiveFlowCount", "LoadBalancer", "*"],
            ["AWS/NetworkELB", "NewFlowCount", "LoadBalancer", "*"]
          ]
          period = 60
          stat   = "Sum"
          region = var.region
          title  = "Network Load Balancer Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/TransitGateway", "BytesDropCountBlackhole", "TransitGateway", "*"],
            ["AWS/TransitGateway", "PacketDropCountBlackhole", "TransitGateway", "*"]
          ]
          period = 60
          stat   = "Sum"
          region = var.region
          title  = "Transit Gateway Drop Metrics"
        }
      }
    ]
  })
}

# Advanced Network Alarms
resource "aws_cloudwatch_metric_alarm" "network_anomaly" {
  alarm_name          = "${local.name}-network-anomaly"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = "3"
  threshold_metric_id = "ad1"
  alarm_description   = "Network anomaly detected"
  alarm_actions       = [aws_sns_topic.network_alerts.arn]

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "NetworkBytes (Expected)"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "NetworkIn"
      namespace   = "AWS/EC2"
      period      = "120"
      stat        = "Average"
      unit        = "Bytes"
    }
  }
}

# Network Performance Monitoring
resource "aws_vpc_endpoint_service" "network_monitoring" {
  acceptance_required        = false
  network_load_balancer_arns = [var.monitoring_nlb_arn]

  tags = merge(local.tags, {
    Name = "${local.name}-network-monitoring"
  })
}

# Flow Logs Enhanced Processing
resource "aws_kinesis_firehose_delivery_stream" "flow_logs" {
  name        = "${local.name}-flow-logs-stream"
  destination = "s3"

  s3_configuration {
    role_arn           = aws_iam_role.firehose.arn
    bucket_arn         = aws_s3_bucket.flow_logs_archive.arn
    prefix             = "flow-logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    compression_format = "GZIP"
  }

  tags = local.tags
}

# Real-time Network Analytics
resource "aws_kinesis_analytics_application" "network_analytics" {
  name = "${local.name}-network-analytics"

  inputs {
    name_prefix = "SOURCE_SQL_STREAM"

    kinesis_firehose {
      resource_arn = aws_kinesis_firehose_delivery_stream.flow_logs.arn
      role_arn     = aws_iam_role.kinesis_analytics.arn
    }

    schema_version = 1

    schema_definition {
      record_columns {
        mapping  = "$.srcaddr"
        name     = "source_address"
        sql_type = "VARCHAR(64)"
      }
      record_columns {
        mapping  = "$.dstaddr"
        name     = "destination_address"
        sql_type = "VARCHAR(64)"
      }
      record_columns {
        mapping  = "$.bytes"
        name     = "bytes_transferred"
        sql_type = "BIGINT"
      }
    }
  }
}

# infrastructure/modules/networking/advanced_monitoring.tf

# Advanced Network Analytics
resource "aws_kinesis_analytics_application" "network_analytics_advanced" {
  name = "${local.name}-network-analytics-advanced"

  inputs {
    name_prefix = "SOURCE_SQL_STREAM"

    kinesis_firehose {
      resource_arn = aws_kinesis_firehose_delivery_stream.flow_logs.arn
      role_arn     = aws_iam_role.kinesis_analytics.arn
    }

    parallelism {
      count = 2
    }

    processing_configuration {
      lambda {
        resource_arn = aws_lambda_function.stream_preprocessing.arn
        role_arn     = aws_iam_role.kinesis_preprocessing.arn
      }
    }

    schema_version = 1

    schema_definition {
      record_columns {
        mapping  = "$.anomaly_score"
        name     = "anomaly_score"
        sql_type = "DOUBLE"
      }
      record_columns {
        mapping  = "$.traffic_pattern"
        name     = "traffic_pattern"
        sql_type = "VARCHAR(64)"
      }
    }
  }

  application_configuration {
    sql_application_configuration {
      input {
        name_prefix = "SOURCE_SQL_STREAM"

        input_parallelism {
          count = 2
        }

        input_schema {
          record_format {
            mapping_parameters {
              json {
                record_row_path = "$"
              }
            }
          }
        }
      }
    }
  }
}

# Advanced Alerting System
resource "aws_cloudwatch_composite_alarm" "network_health" {
  alarm_name        = "${local.name}-network-health"
  alarm_description = "Composite alarm for network health"

  alarm_rule = <<-EOF
    ALARM(${aws_cloudwatch_metric_alarm.latency.alarm_name}) OR
    ALARM(${aws_cloudwatch_metric_alarm.packet_loss.alarm_name}) OR
    ALARM(${aws_cloudwatch_metric_alarm.error_rate.alarm_name})
  EOF

  alarm_actions = [aws_sns_topic.critical_alerts.arn]
  ok_actions    = [aws_sns_topic.recovery_notifications.arn]
}

# Network Performance Baseline
resource "aws_cloudwatch_metric_alarm" "performance_baseline" {
  alarm_name          = "${local.name}-performance-baseline"
  comparison_operator = "LessThanLowerThreshold"
  evaluation_periods  = "3"
  metric_name         = "NetworkPerformanceScore"
  namespace           = "Custom/Network"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"

  metric_query {
    id          = "m1"
    return_data = true
    metric {
      metric_name = "Throughput"
      namespace   = "AWS/NetworkELB"
      period      = "300"
      stat        = "Average"
      unit        = "Bytes/Second"
    }
  }
}

# Machine Learning-based Anomaly Detection
resource "aws_cloudwatch_metric_alarm" "ml_anomaly" {
  alarm_name          = "${local.name}-ml-anomaly"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = "2"
  threshold_metric_id = "m1"

  metric_query {
    id          = "m1"
    expression  = "ANOMALY_DETECTION_BAND(m2, 2)"
    label       = "Network Traffic (Expected)"
    return_data = true
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "BytesProcessed"
      namespace   = "AWS/NetworkELB"
      period      = "60"
      stat        = "Sum"
      dimensions = {
        LoadBalancer = var.nlb_name
      }
    }
  }
}
