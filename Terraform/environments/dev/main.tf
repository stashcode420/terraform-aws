# environments/dev/main.tf
module "networking" {
  source = "../../modules/networking"

  environment = "dev"
  project     = "trading-platform"
  region      = "us-east-1"

  # VPC Configuration
  vpc_cidr            = "10.1.0.0/16"
  azs                 = ["us-east-1a", "us-east-1b"]
  public_subnets      = ["10.1.1.0/24", "10.1.4.0/24"]
  private_app_subnets = ["10.1.2.0/24", "10.1.5.0/24"]
  private_db_subnets  = ["10.1.3.0/24", "10.1.6.0/24"]

  # Cost optimization for dev
  enable_nat_gateway = true
  single_nat_gateway = true # Single NAT Gateway for dev to save costs

  # Security features for dev
  enable_vpn_gateway        = false
  enable_network_firewall   = false
  enable_global_accelerator = false

  # DR and advanced features (minimal for dev)
  enable_vpc_peering       = false
  enable_advanced_security = false

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

module "dr" {
  count  = var.enable_dr ? 1 : 0
  source = "../dr"

  environment    = var.environment
  project        = var.project
  primary_region = var.region
  dr_region      = var.dr_region
  primary_vpc_id = module.vpc.vpc_id
  dr_vpc_id      = var.dr_vpc_id

  providers = {
    aws    = aws
    aws.dr = aws.dr
  }
}


# environments/dev/eks.tf

module "eks" {
  source = "../../modules/eks"

  environment = "dev"
  project     = local.project
  region      = var.region

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  eks_version = "1.28"

  # Node Groups for Dev
  node_groups = {
    general = {
      instance_types = ["t3.xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      disk_size      = 50
      labels = {
        Environment = "dev"
      }
      taints = []
    }

    arbiters = {
      instance_types = ["t3.2xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      disk_size      = 50
      labels = {
        role = "arbiter"
      }
      taints = []
    }
  }

  # Dev-specific configurations
  enable_cluster_autoscaler = true
  enable_prometheus         = true
  enable_app_mesh           = false # Disabled for dev

  tags = local.tags
}

# environments/dev/monitoring.tf

module "monitoring" {
  source = "../../modules/monitoring"

  environment                   = "dev"
  project                       = local.project
  region                        = var.region
  vpc_id                        = module.networking.vpc_id
  private_subnet_ids            = module.networking.private_subnet_ids
  eks_cluster_name              = module.eks.cluster_name
  eks_cluster_security_group_id = module.eks.cluster_security_group_id

  # Dev-specific configurations
  retention_days            = 30 # Shorter retention for dev
  opensearch_instance_type  = "t3.medium.search"
  opensearch_instance_count = 1
  enable_dedicated_master   = false

  # Alert configurations
  alert_endpoints = {
    email = ["dev-team@company.com"]
    slack = var.dev_slack_webhook_url
  }

  # Dev thresholds
  thresholds = {
    order_latency_ms     = 500 # More relaxed latency threshold for dev
    market_data_delay_ms = 1000
    cpu_threshold        = 80
    memory_threshold     = 80
  }

  tags = local.tags
}

# environments/dev/security.tf

module "security" {
  source = "../../modules/security"

  environment = "dev"
  project     = local.project
  region      = var.region

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  eks_cluster_name   = module.eks.cluster_name

  # Dev-specific configurations
  enable_shield_advanced = false # Disabled for dev to save costs
  enable_waf             = true

  trading_api_domain = "dev-api.trading.company.com"

  allowed_ip_ranges = [
    "10.0.0.0/8",   # Internal network
    "172.16.0.0/12" # VPN network
  ]

  api_gateway_arn   = module.api.gateway_arn
  load_balancer_arn = module.networking.load_balancer_arn

  tags = local.tags
}

# environments/dev/database.tf

module "database" {
  source = "../../modules/database"

  environment = "dev"
  project     = local.project
  region      = var.region

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  kms_key_arn        = module.security.kms_key_arn

  # Dev-specific configurations
  instance_class  = "db.t3.large"
  redis_node_type = "cache.t3.medium"
  multi_az        = false

  backup_retention_period = 7
  log_retention_days      = 30

  allowed_security_groups = [
    module.eks.node_security_group_id
  ]

  alarm_actions = [module.monitoring.sns_topic_arn]

  tags = local.tags
}

# environments/main.tf
module "control_tower" {
  source = "../modules/control_tower"

  organization_name        = "MyCompany"
  master_account_email    = "master@company.com"
  log_archive_account_email = "logs@company.com"
  audit_account_email     = "audit@company.com"

  environments = [
    {
      name  = "Development"
      email = "dev@company.com"
    },
    {
      name  = "Staging"
      email = "staging@company.com"
    },
    {
      name  = "Production"
      email = "prod@company.com"
    }
  ]

  developer_groups = [
    {
      name        = "JuniorDevelopers"
      description = "Junior Developer Group with limited access"
      users       = ["dev1@company.com", "dev2@company.com"]
      permissions = ["ReadOnlyAccess"]
    },
    {
      name        = "SeniorDevelopers"
      description = "Senior Developer Group with extended access"
      users       = ["senior1@company.com", "senior2@company.com"]
      permissions = ["PowerUserAccess"]
    }
  ]
}