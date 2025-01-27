# # infrastructure/modules/networking/advanced_security.tf

# # Advanced WAF Rules
# resource "aws_wafv2_web_acl" "advanced" {
#   name        = "${local.name}-advanced-waf"
#   description = "Advanced WAF rules for ${local.name}"
#   scope       = "REGIONAL"

#   default_action {
#     allow {}
#   }

#   # IP Rate Limiting by Path
#   rule {
#     name     = "PathBasedRateLimit"
#     priority = 1

#     action {
#       block {}
#     }

#     statement {
#       rate_based_statement {
#         limit              = 1000
#         aggregate_key_type = "IP"
#         custom_key {
#           key = "URI"
#         }
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "PathBasedRateLimit"
#       sampled_requests_enabled   = true
#     }
#   }

#   # Geo Restriction
#   rule {
#     name     = "GeoRestriction"
#     priority = 2

#     action {
#       block {}
#     }

#     statement {
#       geo_match_statement {
#         country_codes = ["CN", "RU", "NK"] # Example blocked countries
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "GeoRestriction"
#       sampled_requests_enabled   = true
#     }
#   }

#   # Advanced XSS Protection
#   rule {
#     name     = "XSSProtection"
#     priority = 3

#     action {
#       block {}
#     }

#     statement {
#       xss_match_statement {
#         field_to_match {
#           body {}
#           query_string {}
#           uri_path {}
#           headers {
#             oversize_handling = "CONTINUE"
#             name              = "cookie"
#           }
#         }
#         text_transformation {
#           priority = 1
#           type     = "HTML_ENTITY_DECODE"
#         }
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "XSSProtection"
#       sampled_requests_enabled   = true
#     }
#   }

#   # Network Firewall Advanced Rules
#   resource "aws_networkfirewall_rule_group" "advanced" {
#     capacity = 100
#     name     = "${local.name}-advanced-rules"
#     type     = "STATEFUL"

#     rule_group {
#       rules_source {
#         stateful_rule {
#           action = "DROP"
#           header {
#             destination      = "ANY"
#             destination_port = "ANY"
#             protocol         = "TCP"
#             source           = "ANY"
#             source_port      = "ANY"
#           }
#           rule_option {
#             keyword  = "sid:1"
#             settings = ["block_encrypted_traffic"]
#           }
#         }

#         # Add custom domain filtering
#         rulesource_custom_domain {
#           domain = "*.malicious-domain.com"
#           type   = "DENYLIST"
#         }
#       }
#     }
#   }
# }
