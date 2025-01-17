# terraform.tfvars
environment = "dev"
region      = "us-east-1"

vpc_config = {
  cidr                = "10.1.0.0/16"
  azs                 = ["us-east-1a", "us-east-1b"]
  private_app_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  private_db_subnets  = ["10.1.3.0/24", "10.1.4.0/24"]
  public_subnets      = ["10.1.5.0/24", "10.1.6.0/24"]
}

eks_config = {
  cluster_version = "1.28"
  instance_types  = ["t3.large"]
  desired_size    = 2
  min_size        = 1
  max_size        = 3
}

tags = {
  Environment = "dev"
  Project     = "trading-platform"
  ManagedBy   = "terraform"
}
