# infrastructure/modules/networking/dns.tf
resource "aws_route53_private_hosted_zone" "main" {
  name = "${var.environment}.${var.project}.internal"
  vpc {
    vpc_id = module.vpc.vpc_id
  }

  tags = local.tags
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.environment}.${var.project}.local"
  description = "Service discovery namespace for ${var.environment}"
  vpc         = module.vpc.vpc_id

  tags = local.tags
}
