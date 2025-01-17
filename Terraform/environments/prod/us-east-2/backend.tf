# infrastructure/environments/prod/us-east-2/backend.tf

terraform {
  backend "s3" {
    bucket         = "trading-platform-terraform-prod-us-east-2"
    key            = "prod/us-east-2/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock-prod"
    encrypt        = true
  }
}
