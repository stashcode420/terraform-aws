# infrastructure/environments/prod/us-east-1/providers.tf

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "prod"
      Project     = "trading-platform"
      ManagedBy   = "terraform"
    }
  }
}

provider "aws" {
  alias  = "dr"
  region = "us-east-2"

  default_tags {
    tags = {
      Environment = "prod-dr"
      Project     = "trading-platform"
      ManagedBy   = "terraform"
    }
  }
}
