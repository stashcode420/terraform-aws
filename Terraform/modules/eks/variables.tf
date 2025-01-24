# modules/eks/variables.tf

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "create_kube_system_namespace" {
  description = "Create kube-system namespace"
  type        = bool
  default     = false  # Usually false as EKS creates this by default
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

# variable "vpc_id" {
#   description = "VPC ID"
#   type        = string
# }

# variable "private_subnet_ids" {
#   description = "Private subnet IDs"
#   type        = list(string)
# }

variable "enable_public_access" {
  description = "Enable public API endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = []  # Empty default since we're not using public access
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 90
}

variable "node_groups" {
  description = "EKS node groups configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    desired_size   = number
    min_size      = number
    max_size      = number
    disk_size     = number
    labels        = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
}

# Add missing variables
variable "enable_alb_controller" {
  description = "Enable AWS Load Balancer Controller"
  type        = bool
  default     = false
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Enable Prometheus monitoring"
  type        = bool
  default     = false
}

# variable "vpc_cni_version" {
#   description = "VPC CNI addon version"
#   type        = string
#   default     = "v1.12.6-eksbuild.2"
# }

variable "coredns_version" {
  description = "CoreDNS addon version"
  type        = string
  default     = "v1.10.1-eksbuild.1"
}

# variable "kube_proxy_version" {
#   description = "Kube Proxy addon version"
#   type        = string
#   default     = "v1.27.1-eksbuild.1"
# }

variable "alb_controller_version" {
  description = "AWS Load Balancer Controller version"
  type        = string
  default     = "1.4.7"
}

variable "cluster_autoscaler_version" {
  description = "Cluster Autoscaler version"
  type        = string
  default     = "9.29.0"
}

variable "prometheus_stack_version" {
  description = "Prometheus Stack version"
  type        = string
  default     = "45.7.1"
}

variable "prometheus_retention_days" {
  description = "Prometheus retention period in days"
  type        = number
  default     = 15
}

variable "prometheus_storage_class" {
  description = "Storage class for Prometheus"
  type        = string
  default     = "gp3"
}

variable "grafana_domain" {
  description = "Domain name for Grafana"
  type        = string
  default     = ""
}

variable "fluent_bit_version" {
  description = "Fluent Bit version"
  type        = string
  default     = "0.20.9"
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alerting"
  type        = string
  default     = ""
}

variable "enable_cluster_autoscaler" {
  description = "Enable cluster autoscaler"
  type        = bool
  default     = false
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "change-me-123"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"  # Change this to your desired default region
}


variable "enable_logging" {
  description = "Enable logging namespace and resources"
  type        = bool
  default     = true
}