# global_accelerator.tf

resource "aws_globalaccelerator_accelerator" "main" {
  count = var.enable_global_accelerator ? 1 : 0

  name            = "${local.name}-accelerator"
  ip_address_type = "IPV4"
  enabled         = true

  attributes {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = aws_s3_bucket.flow_logs[0].bucket
    flow_logs_s3_prefix = "global-accelerator"
  }

  tags = local.tags
}

resource "aws_globalaccelerator_listener" "https" {
  count = var.enable_global_accelerator ? 1 : 0

  accelerator_arn = aws_globalaccelerator_accelerator.main[0].id
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_s3_bucket" "flow_logs" {
  count = var.enable_global_accelerator ? 1 : 0

  bucket        = "${local.name}-flow-logs-${var.region}"
  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_versioning" "flow_logs" {
  count = var.enable_global_accelerator ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  count = var.enable_global_accelerator ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  count = var.enable_global_accelerator ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}