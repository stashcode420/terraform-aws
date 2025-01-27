terraform {
  backend "s3" {
    bucket         = "trading-platform-terraform-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-dev"
    encrypt        = true
  }
}
