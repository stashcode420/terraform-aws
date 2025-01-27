# infrastructure/environments/dev/providers.tf

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "trading-platform"
      ManagedBy   = "terraform"
    }
  }
}

