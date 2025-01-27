# modules/security/certificates.tf
resource "aws_acm_certificate" "trading_api" {
  domain_name       = var.trading_api_domain
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.trading_api_domain}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_acm_certificate_validation" "trading_api" {
  certificate_arn         = aws_acm_certificate.trading_api.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
