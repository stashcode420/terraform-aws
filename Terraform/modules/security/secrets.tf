# modules/security/secrets.tf
resource "aws_secretsmanager_secret" "trading_api" {
  name        = "${local.name}/trading-api"
  description = "Trading API credentials and configurations"
  kms_key_id  = aws_kms_key.trading.id

  tags = local.tags
}

resource "aws_secretsmanager_secret" "market_data" {
  name        = "${local.name}/market-data"
  description = "Market data feed credentials"
  kms_key_id  = aws_kms_key.trading.id

  tags = local.tags
}

resource "aws_secretsmanager_secret" "fix_session" {
  name        = "${local.name}/fix-session"
  description = "FIX session configurations"
  kms_key_id  = aws_kms_key.trading.id

  tags = local.tags
}
