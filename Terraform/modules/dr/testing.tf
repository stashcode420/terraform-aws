# modules/dr/testing.tf
# Lambda function for DR testing
resource "aws_lambda_function" "dr_test" {
  filename      = "dr_test.zip"
  function_name = "${local.name_prefix}-dr-test"
  role          = aws_iam_role.dr_test.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"

  environment {
    variables = {
      PRIMARY_REGION = var.primary_region
      DR_REGION      = var.dr_region
      PRIMARY_VPC    = var.primary_vpc_id
      DR_VPC         = var.dr_vpc_id
    }
  }
}
