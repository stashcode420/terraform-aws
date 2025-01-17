# modules/eks/monitoring.tf
resource "aws_cloudwatch_metric_alarm" "node_cpu" {
  for_each = var.node_groups

  alarm_name          = "${local.name}-${each.key}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.main[each.key].resources[0].autoscaling_groups[0].name
  }
}

resource "aws_cloudwatch_metric_alarm" "node_memory" {
  for_each = var.node_groups

  alarm_name          = "${local.name}-${each.key}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "MemoryUtilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EC2 memory utilization"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
    NodeGroup   = each.key
  }
}
