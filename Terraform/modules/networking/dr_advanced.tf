# infrastructure/modules/networking/dr_advanced.tf

# Route53 Failover Configuration
resource "aws_route53_record" "primary" {
  zone_id = var.route53_zone_id
  name    = var.service_domain
  type    = "A"

  failover_routing_policy {
    type = "PRIMARY"
  }

  alias {
    name                   = var.primary_alb_dns
    zone_id                = var.primary_alb_zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.main.id
}

resource "aws_route53_record" "secondary" {
  provider = aws.dr
  zone_id  = var.route53_zone_id
  name     = var.service_domain
  type     = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = var.dr_alb_dns
    zone_id                = var.dr_alb_zone_id
    evaluate_target_health = true
  }
}

# Lambda for DR Automation
resource "aws_lambda_function" "dr_failover" {
  filename      = "dr_failover.zip"
  function_name = "${local.name}-dr-failover"
  role          = aws_iam_role.dr_failover.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 300

  environment {
    variables = {
      PRIMARY_REGION = var.region
      DR_REGION      = var.dr_region
      VPC_ID         = module.vpc.vpc_id
      DR_VPC_ID      = module.dr_vpc.vpc_id
    }
  }

  tags = local.tags
}

# infrastructure/modules/networking/advanced_dr.tf

# Complex DR State Machine
resource "aws_sfn_state_machine" "advanced_dr" {
  name     = "${local.name}-advanced-dr"
  role_arn = aws_iam_role.dr_state_machine.arn

  definition = jsonencode({
    StartAt = "AssessFailoverTrigger"
    States = {
      AssessFailoverTrigger = {
        Type = "Choice"
        Choices = [
          {
            Variable     = "$.failoverType"
            StringEquals = "PLANNED"
            Next         = "InitiatePlannedFailover"
          },
          {
            Variable     = "$.failoverType"
            StringEquals = "UNPLANNED"
            Next         = "AssessImpact"
          }
        ]
      },
      AssessImpact = {
        Type     = "Task"
        Resource = aws_lambda_function.impact_assessment.arn
        Next     = "DetermineFailoverStrategy"
      },
      DetermineFailoverStrategy = {
        Type = "Choice"
        Choices = [
          {
            Variable     = "$.impactLevel"
            StringEquals = "HIGH"
            Next         = "InitiateEmergencyFailover"
          },
          {
            Variable     = "$.impactLevel"
            StringEquals = "MEDIUM"
            Next         = "InitiateGradualFailover"
          }
        ]
      },
      InitiateEmergencyFailover = {
        Type = "Parallel"
        Branches = [
          {
            StartAt = "UpdateDNS"
            States = {
              UpdateDNS = {
                Type     = "Task"
                Resource = aws_lambda_function.emergency_dns_update.arn
                Next     = "ValidateDNS"
              },
              ValidateDNS = {
                Type     = "Task"
                Resource = aws_lambda_function.dns_validation.arn
                End      = true
              }
            }
          },
          {
            StartAt = "SwitchTraffic"
            States = {
              SwitchTraffic = {
                Type     = "Task"
                Resource = aws_lambda_function.emergency_traffic_switch.arn
                Next     = "ValidateTraffic"
              },
              ValidateTraffic = {
                Type     = "Task"
                Resource = aws_lambda_function.traffic_validation.arn
                End      = true
              }
            }
          }
        ],
        Next = "PostFailoverValidation"
      }
    }
  })
}

# DR Testing Framework
resource "aws_lambda_function" "dr_test" {
  filename      = "dr_test.zip"
  function_name = "${local.name}-dr-test"
  role          = aws_iam_role.dr_test.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"

  environment {
    variables = {
      TEST_SCENARIOS = jsonencode([
        "network_partition",
        "database_failure",
        "region_outage",
        "partial_failure"
      ])
    }
  }
}
