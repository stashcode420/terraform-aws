# modules/dr/failover.tf
# Step Functions for failover orchestration
resource "aws_sfn_state_machine" "dr_failover" {
  name     = "${local.name_prefix}-dr-failover"
  role_arn = aws_iam_role.dr_failover.arn

  definition = jsonencode({
    StartAt = "CheckPrimaryHealth"
    States = {
      CheckPrimaryHealth = {
        Type     = "Task"
        Resource = aws_lambda_function.health_check.arn
        Next     = "EvaluateHealth"
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
                End      = true
              }
            }
          }
        ],
        Next = "NotifyTeam"
      }
      NotifyTeam = {
        Type     = "Task"
        Resource = "arn:aws:states:::sns:publish"
        End      = true
      }
    }
  })
}
