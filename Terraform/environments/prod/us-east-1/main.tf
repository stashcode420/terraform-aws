# environments/dev/main.tf
module "networking" {
  source = "../../../modules/networking"

  environment = "prod"
  project     = "trading-platform"
  region      = "us-east-1"

  # VPC Configuration
  vpc_cidr            = "10.0.0.0/16"
  azs                 = ["us-east-1a", "us-east-1b"]
  public_subnets      = ["10.0.1.0/24", "10.0.4.0/24"]
  private_app_subnets = ["10.0.2.0/24", "10.0.5.0/24"]
  private_db_subnets  = ["10.0.3.0/24", "10.0.6.0/24"]

  # High availability configurations
  enable_nat_gateway        = true
  single_nat_gateway        = false # Multiple NAT Gateways for HA
  enable_vpn_gateway        = true
  enable_network_firewall   = true
  enable_global_accelerator = true

  # DR and advanced features
  enable_vpc_peering       = true
  enable_advanced_security = true

  # Trading specific configurations
  trading_platform_config = {
    enable_advanced_protection    = true
    enable_latency_rules          = true
    enable_market_data_protection = true
  }

  tags = {
    Environment = "prod"
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

# environments/prod/us-east-1/eks.tf

module "eks" {
  source = "../../../modules/eks"

  environment = "prod"
  project     = local.project
  region      = var.region

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  eks_version = "1.28"

  # Node Groups for Production
  node_groups = {
    general = {
      instance_types = ["c6i.2xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 3
      min_size       = 3
      max_size       = 5
      disk_size      = 100
      labels = {
        Environment = "prod"
      }
      taints = []
    }

    arbiters = {
      instance_types = ["c6i.4xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 3
      min_size       = 3
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
      desired_size   = 2
      min_size       = 2
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

    executors = {
      instance_types = ["c6i.2xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 2
      max_size       = 4
      disk_size      = 100
      labels = {
        role = "executor"
      }
      taints = [{
        key    = "workload"
        value  = "executor"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  enable_cluster_autoscaler = true
  enable_prometheus         = true
  enable_app_mesh           = true

  tags = merge(local.tags, {
    Region = "primary"
  })
}

# environments/prod/us-east-1/monitoring.tf

module "monitoring" {
  source = "../../../modules/monitoring"

  environment                   = "prod"
  project                       = local.project
  region                        = var.region
  vpc_id                        = module.networking.vpc_id
  private_subnet_ids            = module.networking.private_subnet_ids
  eks_cluster_name              = module.eks.cluster_name
  eks_cluster_security_group_id = module.eks.cluster_security_group_id

  # Production-specific configurations
  retention_days            = 90
  opensearch_instance_type  = "r6g.2xlarge.search"
  opensearch_instance_count = 3
  enable_dedicated_master   = true

  # High availability settings
  multi_az               = true
  zone_awareness_enabled = true

  # Alert configurations
  alert_endpoints = {
    email     = ["trading-alerts@company.com"]
    slack     = var.prod_slack_webhook_url
    pagerduty = var.prod_pagerduty_key
    sms       = var.prod_alert_phone_numbers
  }

  # Production thresholds
  thresholds = {
    order_latency_ms     = 100
    market_data_delay_ms = 200
    cpu_threshold        = 70
    memory_threshold     = 70
  }

  # Cross-region monitoring
  enable_cross_region_monitoring = true
  secondary_region               = "us-east-2"

  tags = local.tags
}

# environments/prod/us-east-1/security.tf

module "security" {
  source = "../../../modules/security"

  environment = "prod"
  project     = local.project
  region      = var.region

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  eks_cluster_name   = module.eks.cluster_name

  # Production-specific configurations
  enable_shield_advanced = true
  enable_waf             = true

  trading_api_domain = "api.trading.company.com"

  # Stricter security settings for production
  waf_rate_limits = {
    requests_per_ip     = 5000
    api_requests_per_ip = 2000
  }

  # Enhanced audit logging
  audit_log_settings = {
    retention_days        = 365
    enable_encryption     = true
    enable_log_validation = true
  }

  # GuardDuty settings
  guardduty_settings = {
    finding_publishing_frequency = "FIFTEEN_MINUTES"
    enable_s3_logs               = true
    enable_kubernetes_logs       = true
  }

  # Additional security features
  enable_multi_region_trail  = true
  enable_cloudtrail_insights = true
  enable_securityhub         = true

  api_gateway_arn   = module.api.gateway_arn
  load_balancer_arn = module.networking.load_balancer_arn

  tags = local.tags
}

# environments/prod/us-east-1/database.tf

module "database" {
  source = "../../../modules/database"

  environment = "prod"
  project     = local.project
  region      = var.region

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  kms_key_arn        = module.security.kms_key_arn

  # Production-specific configurations
  instance_class  = "db.r6i.2xlarge"
  redis_node_type = "cache.r6g.xlarge"
  multi_az        = true

  backup_retention_period = 30
  log_retention_days      = 90

  # Enhanced monitoring
  monitoring_interval                   = 10
  performance_insights_retention_period = 7

  # Additional production settings
  deletion_protection = true
  skip_final_snapshot = false

  allowed_security_groups = [
    module.eks.node_security_group_id
  ]

  alarm_actions = [module.monitoring.sns_topic_arn]

  # Cross-region replication settings
  enable_cross_region_backup = true
  replica_regions            = ["us-east-2"]

  tags = local.tags
}
