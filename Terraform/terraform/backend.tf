# infrastructure/terraform/backend/main.tf

module "terraform_state_backend" {
  source = "../../modules/backend"

  for_each = {
    dev     = { environment = "dev" }
    staging = { environment = "staging" }
    prod = {
      environment = "prod"
      regions     = ["us-east-1", "us-east-2"]
    }
  }

  environment = each.value.environment
  regions     = try(each.value.regions, [var.default_region])

  bucket_config = {
    versioning            = true
    enable_encryption     = true
    lifecycle_rules       = true
    retention_period_days = 90
    logging_enabled       = true
  }

  dynamodb_config = {
    billing_mode      = "PAY_PER_REQUEST"
    hash_key          = "LockID"
    enable_encryption = true
  }
}
