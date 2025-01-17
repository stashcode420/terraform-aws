# environments/global/dns.tf
resource "aws_route53_zone" "main" {
  name = "trading-platform.com"

  tags = merge(var.default_tags, {
    Name = "trading-platform-zone"
  })
}

resource "aws_route53_zone" "internal" {
  name = "trading-platform.internal"

  vpc {
    vpc_id = data.aws_vpc.selected.id
  }

  tags = merge(var.default_tags, {
    Name = "trading-platform-internal-zone"
  })
}
