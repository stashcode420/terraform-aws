# # infrastructure/modules/networking/security.tf

# # WAF Configuration for ALB
# resource "aws_wafv2_web_acl" "main" {
#   name        = "${local.name}-waf-acl"
#   description = "WAF ACL for ${local.name}"
#   scope       = "REGIONAL"

#   default_action {
#     allow {}
#   }

#   # Rate limiting rule
#   rule {
#     name     = "RateLimit"
#     priority = 1

#     override_action {
#       none {}
#     }

#     statement {
#       rate_based_statement {
#         limit              = 2000
#         aggregate_key_type = "IP"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "RateLimitMetric"
#       sampled_requests_enabled   = true
#     }
#   }

#   # SQL Injection protection
#   rule {
#     name     = "SQLInjectionProtection"
#     priority = 2

#     override_action {
#       none {}
#     }

#     statement {
#       sql_injection_match_statement {
#         field_to_match {
#           body {}
#         }
#         text_transformation {
#           priority = 1
#           type     = "URL_DECODE"
#         }
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "SQLInjectionProtectionMetric"
#       sampled_requests_enabled   = true
#     }
#   }

#   tags = local.tags
# }

# # Shield Advanced
# resource "aws_shield_protection" "alb" {
#   name         = "${local.name}-shield-protection"
#   resource_arn = var.alb_arn

#   tags = local.tags
# }

# # VPC Traffic Mirroring
# resource "aws_ec2_traffic_mirror_filter" "main" {
#   description      = "Traffic mirror filter for ${local.name}"
#   network_services = ["amazon-dns"]

#   tags = local.tags
# }

# resource "aws_ec2_traffic_mirror_target" "main" {
#   network_load_balancer_arn = var.nlb_arn

#   tags = local.tags
# }
