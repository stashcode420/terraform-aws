# infrastructure/modules/networking/ddos_protection.tf

# Advanced Shield Configuration
resource "aws_shield_protection_group" "advanced" {
  protection_group_id = "${local.name}-protection-group"
  aggregation         = "MAX"
  pattern             = "BY_RESOURCE_TYPE"

  members {
    resource_type = "ELASTIC_IP_ALLOCATION"
  }

  members {
    resource_type = "APPLICATION_LOAD_BALANCER"
  }

  members {
    resource_type = "NETWORK_LOAD_BALANCER"
  }
}

# Advanced WAF Rate-Based Rules
resource "aws_wafv2_rule_group" "rate_protection" {
  name        = "${local.name}-rate-protection"
  description = "Advanced rate-based protection"
  scope       = "REGIONAL"
  capacity    = 1000

  rule {
    name     = "APIRateLimit"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "APIRateLimit"
      sampled_requests_enabled   = true
    }
  }

  # Advanced Header Inspection
  rule {
    name     = "HeaderInspection"
    priority = 2

    override_action {
      none {}
    }

    statement {
      and_statement {
        statements = [
          {
            byte_match_statement = {
              field_to_match = {
                headers = {
                  name = "user-agent"
                }
              }
              positional_constraint = "CONTAINS"
              search_string         = "bot"
              text_transformation = [
                {
                  priority = 1
                  type     = "LOWERCASE"
                }
              ]
            }
          },
          {
            rate_based_statement = {
              limit              = 100
              aggregate_key_type = "IP"
            }
          }
        ]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "HeaderInspection"
      sampled_requests_enabled   = true
    }
  }
}

# Network ACL Enhanced Rules
resource "aws_network_acl" "enhanced" {
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # SYN Flood Protection
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
    tcp_flags = {
      syn = true
      ack = false
    }
  }

  tags = local.tags
}
