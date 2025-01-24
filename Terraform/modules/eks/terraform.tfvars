# terraform.tfvars

# Project Information
project     = "trading-platform"
environment = "prod"

# Cluster Configuration
kubernetes_version = "1.28"
enable_public_access = true
# public_access_cidrs = ["10.0.0.0/8"]  # Your corporate CIDR

# # VPC Configuration
# vpc_id = "vpc-12345678"  # Replace with your VPC ID
# private_subnet_ids = [
#   "subnet-12345678",  # Replace with your subnet IDs
#   "subnet-87654321",
#   "subnet-11223344"
# ]

# Node Groups Configuration
node_groups = {
  system = {
    instance_types = ["t3.medium"] # You can make that to t3.large
    capacity_type  = "ON_DEMAND"
    desired_size   = 1 # Chage it for desired node size for this node group in EKS
    min_size      = 1 # Change it to the minimum size
    max_size      = 1
    disk_size     = 100
    labels = {
      "node-type" = "system"
    }
    # taints = []
  }
  
#   general = {
#     instance_types = ["t3.xlarge"]
#     capacity_type  = "ON_DEMAND"
#     desired_size   = 3
#     min_size      = 2
#     max_size      = 6
#     disk_size     = 100
#     labels = {
#       "node-type" = "general"
#     }
#     taints = []
#   },
  
#   compute = {
#     instance_types = ["c6i.2xlarge"]
#     capacity_type  = "SPOT"
#     desired_size   = 2
#     min_size      = 0
#     max_size      = 10
#     disk_size     = 100
#     labels = {
#       "node-type" = "compute"
#     }
#     taints = [{
#       key    = "workload"
#       value  = "compute"
#       effect = "NO_SCHEDULE"
#     }]
#   }
}

# Add-ons Configuration
enable_alb_controller = true
enable_cluster_autoscaler = true
enable_container_insights = true
enable_monitoring = true

# Add-ons Versions
# vpc_cni_version = "v1.10.1-eksbuild.1"
coredns_version = "v1.10.1-eksbuild.1"
# kube_proxy_version = "v1.27.1-eksbuild.1"
alb_controller_version = "1.4.7"
cluster_autoscaler_version = "9.29.0"

# Monitoring Configuration
prometheus_stack_version = "45.7.1"
prometheus_retention_days = 15
prometheus_storage_class = "gp3"
grafana_domain = "grafana.your-domain.com"  # Replace with your domain
grafana_admin_password = "YourSecurePassword123!"  # Replace with a secure password

# Logging Configuration
fluent_bit_version = "0.20.9"
log_retention_days = 90

# Alerting Configuration
sns_topic_arn = "arn:aws:sns:region:account-id:topic-name"  # Replace with your SNS topic ARN

# Additional Tags
tags = {
  Owner       = "DevOps"
  CostCenter  = "Platform"
  Environment = "Production"
  Terraform   = "true"
}

aws_region = "us-east-1"  # Change this to your desired region