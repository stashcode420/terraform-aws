# terraform.tfvars
environment = "staging"
region      = "us-east-1"

vpc_config = {
  cidr                = "10.2.0.0/16"
  azs                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_app_subnets = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  private_db_subnets  = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]
  public_subnets      = ["10.2.7.0/24", "10.2.8.0/24", "10.2.9.0/24"]
}

eks_config = {
  cluster_version = "1.28"
  instance_types  = ["t3.xlarge"]
  desired_size    = 3
  min_size        = 2
  max_size        = 5
}

tags = {
  Environment = "staging"
  Project     = "trading-platform"
  ManagedBy   = "terraform"
}
