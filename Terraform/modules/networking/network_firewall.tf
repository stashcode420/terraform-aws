# network_firewall.tf

# Network Firewall Rule Group
resource "aws_networkfirewall_rule_group" "main" {
  count = var.enable_network_firewall ? 1 : 0

  capacity = 100
  name     = "${local.name}-rules"
  type     = "STATEFUL"
  
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.vpc_cidr]
        }
      }
      ip_sets {
        key = "EXTERNAL_NET"
        ip_set {
          definition = ["0.0.0.0/0"]
        }
      }
      port_sets {
        key = "HTTP_PORTS"
        port_set {
          definition = ["80", "443"]
        }
      }
    }

    rules_source {
      stateful_rule {
        action = "PASS"
        header {
          destination      = "ANY"
          destination_port = "443"
          direction       = "FORWARD"
          protocol        = "TCP"
          source          = var.vpc_cidr
          source_port     = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["1"]
        }
      }

      dynamic "stateful_rule" {
        for_each = var.network_firewall_rules
        content {
          action = stateful_rule.value.action
          header {
            destination      = stateful_rule.value.destination
            destination_port = stateful_rule.value.destination_port
            direction       = stateful_rule.value.direction
            protocol        = stateful_rule.value.protocol
            source          = stateful_rule.value.source
            source_port     = stateful_rule.value.source_port
          }
          rule_option {
            keyword  = "sid"
            settings = ["${stateful_rule.key + 2}"]
          }
        }
      }
    }

    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }

  tags = local.tags
}

# Network Firewall Policy
resource "aws_networkfirewall_firewall_policy" "main" {
  count = var.enable_network_firewall ? 1 : 0

  name = "${local.name}-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.main[0].arn
      priority     = 1
    }
  }

  tags = local.tags
}

# Network Firewall
resource "aws_networkfirewall_firewall" "main" {
  count = var.enable_network_firewall ? 1 : 0

  name                = "${local.name}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main[0].arn
  vpc_id              = module.vpc.vpc_id

  subnet_mapping {
    subnet_id = module.vpc.public_subnets[0]
  }

  tags = local.tags
}

# Network Firewall Logging
resource "aws_networkfirewall_logging_configuration" "main" {
  count = var.enable_network_firewall ? 1 : 0

  firewall_arn = aws_networkfirewall_firewall.main[0].arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network_firewall[0].name
      }
      log_destination_type = "CloudWatchLogs"
      log_type            = "ALERT"
    }
  }
}

# CloudWatch Log Group for Network Firewall
resource "aws_cloudwatch_log_group" "network_firewall" {
  count = var.enable_network_firewall ? 1 : 0

  name              = "/aws/network-firewall/${local.name}"
  retention_in_days = var.network_firewall_log_retention

  tags = local.tags
}