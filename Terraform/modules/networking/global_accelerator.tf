# infrastructure/modules/networking/global_accelerator.tf
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

  bucket = "${local.name}-flow-logs-${var.region}"

  tags = local.tags
}
