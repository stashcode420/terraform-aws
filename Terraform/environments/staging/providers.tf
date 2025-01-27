provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "staging"
      Project     = "trading-platform"
      ManagedBy   = "terraform"
    }
  }
}
