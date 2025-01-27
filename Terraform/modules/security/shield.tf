# modules/security/shield.tf
resource "aws_shield_protection" "trading_api" {
  count = var.enable_shield_advanced ? 1 : 0

  name         = "${local.name}-trading-api"
  resource_arn = var.api_gateway_arn

  tags = local.tags
}

resource "aws_shield_protection" "load_balancer" {
  count = var.enable_shield_advanced ? 1 : 0

  name         = "${local.name}-alb"
  resource_arn = var.load_balancer_arn

  tags = local.tags
}

resource "aws_shield_protection_group" "trading" {
  count = var.enable_shield_advanced ? 1 : 0

  protection_group_id = "${local.name}-protection-group"
  aggregation         = "MAX"
  pattern             = "ALL"

  resource_type = "APPLICATIONLOADBALANCER"

  members = [
    var.load_balancer_arn,
    var.api_gateway_arn
  ]

  tags = local.tags
}
