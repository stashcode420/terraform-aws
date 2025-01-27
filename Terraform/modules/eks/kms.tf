resource "aws_kms_key" "cloudwatch" {
  description             = "KMS key for CloudWatch Logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                 = data.aws_iam_policy_document.cloudwatch_kms.json
  tags                   = local.tags
}

resource "aws_kms_alias" "cloudwatch" {
  name          = "alias/${local.name}-cloudwatch"
  target_key_id = aws_kms_key.cloudwatch.key_id
}

data "aws_iam_policy_document" "cloudwatch_kms" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudWatch to encrypt logs"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "logs.${data.aws_region.current.name}.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }
}