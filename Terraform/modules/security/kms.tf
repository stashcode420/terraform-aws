# modules/security/kms.tf
# KMS key for trading data
resource "aws_kms_key" "trading" {
  description             = "KMS key for trading data encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  multi_region            = var.environment == "prod" ? true : false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Trading Services"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.trading_services.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.tags
}

# KMS key alias
resource "aws_kms_alias" "trading" {
  name          = "alias/${local.name}-trading"
  target_key_id = aws_kms_key.trading.key_id
}
