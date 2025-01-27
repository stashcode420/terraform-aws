# # infrastructure/modules/networking/monitoring.tf
# resource "aws_flow_log" "vpc_flow_logs" {
#   iam_role_arn    = aws_iam_role.vpc_flow_log.arn
#   log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
#   traffic_type    = "ALL"
#   vpc_id          = module.vpc.vpc_id

#   tags = local.tags
# }

# resource "aws_cloudwatch_metric_alarm" "nat_gateway_errors" {
#   count = var.enable_nat_gateway ? length(module.vpc.nat_public_ips) : 0

#   alarm_name          = "${local.name}-nat-gateway-${count.index + 1}-errors"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "ErrorPortAllocation"
#   namespace           = "AWS/NATGateway"
#   period              = "300"
#   statistic           = "Sum"
#   threshold           = "0"
#   alarm_description   = "NAT Gateway is experiencing port allocation errors"
#   alarm_actions       = [aws_sns_topic.network_alerts.arn]

#   dimensions = {
#     NatGatewayId = module.vpc.nat_gateway_ids[count.index]
#   }
# }
