terraform {
  backend "s3" {
    bucket         = "trading-platform-terraform-staging"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-staging"
    encrypt        = true
  }
}
