# environments/dev/main.tf

module "networking" {
  source = "../../modules/networking"

  environment = "staging"
  project     = "trading-platform"
  region      = "us-east-1"

  # VPC Configuration
  vpc_cidr            = "10.2.0.0/16"
  azs                 = ["us-east-1a", "us-east-1b"]
  public_subnets      = ["10.2.1.0/24", "10.2.4.0/24"]
  private_app_subnets = ["10.2.2.0/24", "10.2.5.0/24"]
  private_db_subnets  = ["10.2.3.0/24", "10.2.6.0/24"]

  # Moderate security features for staging
  enable_nat_gateway        = true
  single_nat_gateway        = true
  enable_vpn_gateway        = true
  enable_network_firewall   = true
  enable_global_accelerator = true

  # DR features (enabled but simplified)
  enable_vpc_peering       = true
  enable_advanced_security = true

  tags = {
    Environment = "staging"
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

# environments/staging/eks.tf

module "eks" {
  source = "../../modules/eks"

  environment = "staging"
  project     = local.project
  region      = var.region

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  eks_version = "1.28"

  # Node Groups for Staging
  node_groups = {
    general = {
      instance_types = ["t3.2xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 2
      max_size       = 4
      disk_size      = 100
      labels = {
        Environment = "staging"
      }
      taints = []
    }

    arbiters = {
      instance_types = ["c6i.2xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 2
      max_size       = 3
      disk_size      = 100
      labels = {
        role = "arbiter"
      }
      taints = [{
        key    = "workload"
        value  = "arbiter"
        effect = "NO_SCHEDULE"
      }]
    }

    market_data = {
      instance_types = ["r6i.xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      disk_size      = 100
      labels = {
        role = "market-data"
      }
      taints = []
    }
  }

  enable_cluster_autoscaler = true
  enable_prometheus         = true
  enable_app_mesh           = true

  tags = local.tags
}

# environments/staging/monitoring.tf

module "monitoring" {
  source = "../../modules/monitoring"

  environment                   = "staging"
  project                       = local.project
  region                        = var.region
  vpc_id                        = module.networking.vpc_id
  private_subnet_ids            = module.networking.private_subnet_ids
  eks_cluster_name              = module.eks.cluster_name
  eks_cluster_security_group_id = module.eks.cluster_security_group_id

  # Staging-specific configurations
  retention_days            = 60
  opensearch_instance_type  = "r6g.large.search"
  opensearch_instance_count = 2
  enable_dedicated_master   = true

  # Alert configurations
  alert_endpoints = {
    email     = ["staging-alerts@company.com"]
    slack     = var.staging_slack_webhook_url
    pagerduty = var.staging_pagerduty_key
  }

  # Staging thresholds
  thresholds = {
    order_latency_ms     = 200
    market_data_delay_ms = 500
    cpu_threshold        = 75
    memory_threshold     = 75
  }

  tags = local.tags
}

# environments/staging/security.tf

module "security" {
  source = "../../modules/security"

  environment = "staging"
  project     = local.project
  region      = var.region

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  eks_cluster_name   = module.eks.cluster_name

  # Staging-specific configurations
  enable_shield_advanced = true
  enable_waf             = true

  trading_api_domain = "staging-api.trading.company.com"

  allowed_ip_ranges = [
    "10.0.0.0/8",    # Internal network
    "172.16.0.0/12", # VPN network
    "192.168.0.0/16" # Partner network
  ]

  # WAF rate limits
  waf_rate_limits = {
    requests_per_ip     = 3000
    api_requests_per_ip = 1000
  }

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
