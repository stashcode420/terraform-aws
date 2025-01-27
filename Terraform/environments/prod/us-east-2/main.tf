# environments/dev/main.tf
module "networking" {
  source = "../../../modules/networking"

  environment = "prod-dr"
  project     = "trading-platform"
  region      = "us-east-2"

  # VPC Configuration for DR
  vpc_cidr            = "10.100.0.0/16"
  azs                 = ["us-east-2a", "us-east-2b"]
  public_subnets      = ["10.100.1.0/24", "10.100.4.0/24"]
  private_app_subnets = ["10.100.2.0/24", "10.100.5.0/24"]
  private_db_subnets  = ["10.100.3.0/24", "10.100.6.0/24"]

  # High availability configurations
  enable_nat_gateway        = true
  single_nat_gateway        = false
  enable_vpn_gateway        = true
  enable_network_firewall   = true
  enable_global_accelerator = true

  # DR specific configurations
  enable_vpc_peering       = true
  enable_advanced_security = true
  primary_region           = "us-east-1"
  primary_vpc_cidr         = "10.0.0.0/16"

  # Trading specific configurations
  trading_platform_config = {
    enable_advanced_protection    = true
    enable_latency_rules          = true
    enable_market_data_protection = true
  }

  tags = {
    Environment = "prod-dr"
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

# environments/prod/us-east-2/eks.tf

module "eks" {
  source = "../../../modules/eks"

  environment = "prod-dr"
  project     = local.project
  region      = "us-east-2"

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  eks_version = "1.28"

  # Similar node groups as primary but with reduced capacity
  node_groups = {
    general = {
      instance_types = ["c6i.2xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 2
      max_size       = 5
      disk_size      = 100
      labels = {
        Environment = "prod-dr"
      }
      taints = []
    }

    arbiters = {
      instance_types = ["c6i.4xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 2
      max_size       = 5
      disk_size      = 200
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
      instance_types = ["r6i.2xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 1
      min_size       = 1
      max_size       = 4
      disk_size      = 200
      labels = {
        role = "market-data"
      }
      taints = [{
        key    = "workload"
        value  = "market-data"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  enable_cluster_autoscaler = true
  enable_prometheus         = true
  enable_app_mesh           = true

  tags = merge(local.tags, {
    Region = "dr"
  })
}

# environments/prod/us-east-2/monitoring.tf

module "monitoring" {
  source = "../../../modules/monitoring"

  environment                   = "prod-dr"
  project                       = local.project
  region                        = var.region
  vpc_id                        = module.networking.vpc_id
  private_subnet_ids            = module.networking.private_subnet_ids
  eks_cluster_name              = module.eks.cluster_name
  eks_cluster_security_group_id = module.eks.cluster_security_group_id

  # DR-specific configurations
  retention_days            = 90
  opensearch_instance_type  = "r6g.2xlarge.search"
  opensearch_instance_count = 3
  enable_dedicated_master   = true

  # High availability settings
  multi_az               = true
  zone_awareness_enabled = true

  # Alert configurations (same as primary for production)
  alert_endpoints = {
    email     = ["trading-alerts@company.com"]
    slack     = var.prod_slack_webhook_url
    pagerduty = var.prod_pagerduty_key
    sms       = var.prod_alert_phone_numbers
  }

  # Same thresholds as primary region
  thresholds = {
    order_latency_ms     = 100
    market_data_delay_ms = 200
    cpu_threshold        = 70
    memory_threshold     = 70
  }

  # Cross-region monitoring
  enable_cross_region_monitoring = true
  primary_region                 = "us-east-1"
  is_dr_region                   = true

  tags = local.tags
}

# environments/prod/us-east-2/security.tf

module "security" {
  source = "../../../modules/security"

  environment = "prod-dr"
  project     = local.project
  region      = "us-east-2"

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  eks_cluster_name   = module.eks.cluster_name

  # Same production configurations as primary region
  enable_shield_advanced = true
  enable_waf             = true

  trading_api_domain = "dr-api.trading.company.com"

  waf_rate_limits = {
    requests_per_ip     = 5000
    api_requests_per_ip = 2000
  }

  # DR-specific settings
  is_dr_region   = true
  primary_region = "us-east-1"

  # Cross-region replication settings
  replication_settings = {
    enable_secret_replication = true
    enable_kms_replication    = true
    enable_log_replication    = true
  }

  audit_log_settings = {
    retention_days        = 365
    enable_encryption     = true
    enable_log_validation = true
  }

  api_gateway_arn   = module.api.gateway_arn
  load_balancer_arn = module.networking.load_balancer_arn

  tags = merge(local.tags, {
    Region = "DR"
  })
}

# environments/prod/us-east-2/database.tf

module "database" {
  source = "../../../modules/database"

  environment = "prod-dr"
  project     = local.project
  region      = "us-east-2"

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  kms_key_arn        = module.security.kms_key_arn

  # DR-specific configurations
  instance_class  = "db.r6i.2xlarge"
  redis_node_type = "cache.r6g.xlarge"
  multi_az        = true

  backup_retention_period = 30
  log_retention_days      = 90

  # Same monitoring settings as primary
  monitoring_interval                   = 10
  performance_insights_retention_period = 7

  deletion_protection = true
  skip_final_snapshot = false

  allowed_security_groups = [
    module.eks.node_security_group_id
  ]

  alarm_actions = [module.monitoring.sns_topic_arn]

  # DR-specific settings
  is_dr_region   = true
  primary_region = "us-east-1"
  source_db_arn  = data.aws_db_instance.primary.arn

  tags = merge(local.tags, {
    Region = "DR"
  })
}
