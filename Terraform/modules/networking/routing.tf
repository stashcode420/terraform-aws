# infrastructure/modules/networking/routing.tf

# Direct Connect Gateway
resource "aws_dx_gateway" "main" {
  name            = "${local.name}-dx-gateway"
  amazon_side_asn = 64512
}

resource "aws_dx_gateway_association" "main" {
  dx_gateway_id         = aws_dx_gateway.main.id
  associated_gateway_id = aws_ec2_transit_gateway.main.id
}

# Site-to-Site VPN
resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.main[0].id
  customer_gateway_id = aws_customer_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = local.tags
}

# Route53 Health Checks
resource "aws_route53_health_check" "main" {
  fqdn              = var.primary_endpoint
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"

  tags = local.tags
}
