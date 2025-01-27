# modules/security/security_groups.tf
# Trading Services Security Group
resource "aws_security_group" "trading_services" {
  name        = "${local.name}-trading-services"
  description = "Security group for trading services"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow HTTPS from ALB"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    self        = true
    description = "Allow internal service communication"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(local.tags, {
    Name = "${local.name}-trading-services"
  })
}

# Market Data Security Group
resource "aws_security_group" "market_data" {
  name        = "${local.name}-market-data"
  description = "Security group for market data services"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.trading_services.id]
    description     = "Allow market data access from trading services"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(local.tags, {
    Name = "${local.name}-market-data"
  })
}
