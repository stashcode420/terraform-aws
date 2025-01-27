# modules/security/outputs.tf
output "security_group_ids" {
  description = "Map of security group IDs"
  value = {
    trading_services = aws_security_group.trading_services.id
    market_data      = aws_security_group.market_data.id
  }
}

output "kms_key_arn" {
  description = "ARN of the KMS key for trading data"
  value       = aws_kms_key.trading.arn
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF web ACL"
  value       = aws_wafv2_web_acl.trading_api.arn
}

output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.trading_api.arn
}

output "audit_bucket_name" {
  description = "Name of the audit logs S3 bucket"
  value       = aws_s3_bucket.audit_logs.id
}
