# terraform.tfvars
environment = "prod"
region      = "us-east-1"

vpc_config = {
  cidr                = "10.0.0.0/16"
  azs                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_app_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_db_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  public_subnets      = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
}

eks_config = {
  cluster_version = "1.28"
  instance_types  = ["r6i.2xlarge"]
  desired_size    = 5
  min_size        = 3
  max_size        = 10
}

tags = {
  Environment = "prod"
  Project     = "trading-platform"
  ManagedBy   = "terraform"
}
