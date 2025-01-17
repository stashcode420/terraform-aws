# modules/monitoring/log_aggregation.tf
resource "aws_kinesis_firehose_delivery_stream" "logs" {
  name        = "${local.name}-logs"
  destination = "opensearch"

  opensearch_configuration {
    domain_arn = aws_opensearch_domain.main.arn
    role_arn   = aws_iam_role.firehose.arn
    index_name = "logs"

    buffering_interval = 60

    s3_backup_mode = "FailedDocumentsOnly"

    processing_configuration {
      enabled = true

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = aws_lambda_function.log_processor.arn
        }
      }
    }
  }

  tags = local.tags
}

# Log processor Lambda function
resource "aws_lambda_function" "log_processor" {
  filename      = "${path.module}/functions/log-processor.zip"
  function_name = "${local.name}-log-processor"
  role          = aws_iam_role.log_processor.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 300

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = local.tags
}
