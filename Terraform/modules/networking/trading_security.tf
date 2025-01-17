# infrastructure/modules/networking/trading_security.tf

# Trading Platform Security Groups
resource "aws_security_group" "trading_platform" {
  name        = "${local.name}-trading-security"
  description = "Security group for trading platform components"
  vpc_id      = module.vpc.vpc_id

  # FIX Protocol
  ingress {
    description = "FIX Protocol"
    from_port   = 8000
    to_port     = 8002
    protocol    = "tcp"
    cidr_blocks = var.fix_server_cidrs
  }

  # Market Data Feed
  ingress {
    description = "Market Data Feed"
    from_port   = 9000
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = var.market_data_cidrs
  }

  # Trading API endpoints
  ingress {
    description = "Trading API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.trading_api_cidrs
  }

  tags = merge(local.tags, {
    Component = "Trading"
  })
}

# Trading Platform WAF Rules
resource "aws_wafv2_rule_group" "trading_protection" {
  name        = "${local.name}-trading-protection"
  description = "Trading platform specific protection"
  scope       = "REGIONAL"
  capacity    = 1000

  rule {
    name     = "TradeRequestValidation"
    priority = 1

    override_action {
      none {}
    }

    statement {
      and_statement {
        statements = [
          {
            byte_match_statement = {
              field_to_match = {
                body = {}
              }
              positional_constraint = "CONTAINS"
              search_string         = "order_type"
              text_transformation = [
                {
                  priority = 1
                  type     = "NONE"
                }
              ]
            }
          },
          {
            rate_based_statement = {
              limit              = 500 # Limit trade requests per IP
              aggregate_key_type = "IP"
            }
          }
        ]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "TradeRequestValidation"
      sampled_requests_enabled   = true
    }
  }

  # High-Frequency Trading Protection
  rule {
    name     = "HFTProtection"
    priority = 2

    override_action {
      none {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "HFTProtection"
      sampled_requests_enabled   = true
    }
  }

  # Trading Hours Restriction
  rule {
    name     = "TradingHours"
    priority = 3

    override_action {
      none {}
    }

    statement {
      time_constraint_statement {
        start_time = "09:30"
        end_time   = "16:00"
        timezone   = "America/New_York"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "TradingHours"
      sampled_requests_enabled   = true
    }
  }
}

# DDoS Protection for Trading Components
resource "aws_shield_protection" "trading_endpoints" {
  name         = "${local.name}-trading-protection"
  resource_arn = aws_lb.trading.arn

  tags = merge(local.tags, {
    Component = "Trading"
  })
}


# infrastructure/modules/networking/trading_security_advanced.tf

# Advanced Trading Security Patterns
resource "aws_wafv2_rule_group" "trading_advanced_protection" {
  name        = "${local.name}-trading-advanced-protection"
  description = "Advanced trading-specific protection rules"
  scope       = "REGIONAL"
  capacity    = 2000

  # Spoofing Detection
  rule {
    name     = "SpoofingDetection"
    priority = 1

    statement {
      and_statement {
        statements = [
          {
            rate_based_statement {
              limit              = 100
              aggregate_key_type = "IP"
            }
          },
          {
            byte_match_statement {
              field_to_match = {
                body = {}
              }
              positional_constraint = "CONTAINS"
              search_string        = "order_cancellation"
              text_transformation  = [
                {
                  priority = 1
                  type     = "NONE"
                }
              ]
            }
          }
        ]
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "SpoofingDetection"
      sampled_requests_enabled  = true
    }
  }

  # Wash Trading Detection
  rule {
    name     = "WashTrading"
    priority = 2

    statement {
      rate_based_statement {
        limit              = 50  # Limit for self-trades
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "WashTrading"
      sampled_requests_enabled  = true
    }
  }

  # Order Flood Protection
  rule {
    name     = "OrderFloodProtection"
    priority = 3

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "OrderFlood"
      sampled_requests_enabled  = true
    }
  }

  # Session Authentication
  rule {
    name     = "SessionValidation"
    priority = 4

    statement {
      and_statement {
        statements = [
          {
            byte_match_statement {
              field_to_match = {
                headers = {
                  name = "trading-session-id"
                }
              }
              positional_constraint = "EXACTLY"
              search_string        = ""  # Will be validated by custom header rules
            }
          }
        ]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "SessionValidation"
      sampled_requests_enabled  = true
    }
  }
}

# Latency-based Security Group
resource "aws_security_group" "latency_sensitive" {
  name        = "${local.name}-latency-sensitive"
  description = "Security group for latency-sensitive trading components"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Low-latency market data"
    from_port   = 28200
    to_port     = 28300
    protocol    = "udp"
    cidr_blocks = var.market_data_cidrs
  }

  egress {
    description = "Order execution"
    from_port   = 28400
    to_port     = 28500
    protocol    = "tcp"
    cidr_blocks = var.exchange_cidrs
  }

  tags = merge(local.tags, {
    Component = "LowLatencyTrading"
  })
}