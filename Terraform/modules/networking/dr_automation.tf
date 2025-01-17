# infrastructure/modules/networking/dr_automation.tf

# DR State Machine
resource "aws_sfn_state_machine" "dr_failover" {
  name     = "${local.name}-dr-failover"
  role_arn = aws_iam_role.dr_state_machine.arn

  definition = jsonencode({
    StartAt = "CheckPrimaryHealth"
    States = {
      CheckPrimaryHealth = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.health_check.function_name
        }
        Next = "EvaluateHealth"
      }
      EvaluateHealth = {
        Type = "Choice"
        Choices = [
          {
            Variable     = "$.healthStatus"
            StringEquals = "UNHEALTHY"
            Next         = "InitiateFailover"
          }
        ]
        Default = "SuccessState"
      }
      InitiateFailover = {
        Type = "Parallel"
        Branches = [
          {
            StartAt = "UpdateDNS"
            States = {
              UpdateDNS = {
                Type     = "Task"
                Resource = aws_lambda_function.update_dns.arn
                Next     = "VerifyDNS"
              }
              VerifyDNS = {
                Type     = "Task"
                Resource = aws_lambda_function.verify_dns.arn
                End      = true
              }
            }
          },
          {
            StartAt = "SwitchTraffic"
            States = {
              SwitchTraffic = {
                Type     = "Task"
                Resource = aws_lambda_function.switch_traffic.arn
                Next     = "VerifyTraffic"
              }
              VerifyTraffic = {
                Type     = "Task"
                Resource = aws_lambda_function.verify_traffic.arn
                End      = true
              }
            }
          }
        ]
        Next = "NotifyTeam"
      }
      NotifyTeam = {
        Type     = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = aws_sns_topic.dr_notifications.arn
          Message  = "DR Failover completed"
        }
        End = true
      }
      SuccessState = {
        Type = "Succeed"
      }
    }
  })
}

# DR Health Check Lambda
resource "aws_lambda_function" "health_check" {
  filename      = "health_check.zip"
  function_name = "${local.name}-health-check"
  role          = aws_iam_role.dr_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"

  environment {
    variables = {
      PRIMARY_ENDPOINTS = jsonencode(var.primary_endpoints)
      HEALTH_CHECK_PATH = "/health"
    }
  }
}
