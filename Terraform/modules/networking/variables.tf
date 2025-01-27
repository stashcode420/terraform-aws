# variables.tf

# Basic Configuration
variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "trading-platform"
}

variable "region" {
  description = "AWS region"
  type        = string
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.4.0/24"]
}

variable "private_app_subnets" {
  description = "CIDR blocks for private application subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.5.0/24"]
}

variable "private_db_subnets" {
  description = "CIDR blocks for private database subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.6.0/24"]
}

# Network Features
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

variable "vpc_flow_log_retention" {
  description = "VPC Flow Log retention in days"
  type        = number
  default     = 90
}

# VPC Endpoints
variable "enable_vpc_endpoints" {
  description = "Enable VPC Endpoints for AWS services"
  type        = map(bool)
  default = {
    s3         = true
    dynamodb   = true
    ecr_api    = true
    ecr_dkr    = true
    cloudwatch = true
    logs       = true
    sts        = true
    ssm        = true
  }
}

# Advanced Configurations
variable "enable_vpc_peering" {
  description = "Enable VPC Peering between regions"
  type        = bool
  default     = true
}

variable "dr_vpc_cidr" {
  description = "CIDR block for DR VPC"
  type        = string
  default     = "10.100.0.0/16"
}

variable "enable_global_accelerator" {
  description = "Enable AWS Global Accelerator"
  type        = bool
  default     = true
}

variable "enable_gateway_endpoints" {
  description = "Map of gateway endpoints to enable"
  type        = map(bool)
  default = {
    s3       = true
    dynamodb = true
  }
}

variable "enable_interface_endpoints" {
  description = "Map of interface endpoints to enable"
  type        = map(bool)
  default = {
    ecr_api              = true
    ecr_dkr              = true
    cloudwatch           = true
    logs                 = true
    ssm                  = true
    sqs                  = true
    sns                  = true
    kms                  = true
    elasticloadbalancing = true
  }
}

variable "network_firewall_policy" {
  description = "Network Firewall policy configuration"
  type = object({
    stateless_default_actions          = list(string)
    stateless_fragment_default_actions = list(string)
  })
  default = {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  }
}

# network_firewall_variables.tf

variable "enable_network_firewall" {
  description = "Enable AWS Network Firewall"
  type        = bool
  default     = false
}

variable "network_firewall_rules" {
  description = "List of Network Firewall rules"
  type = list(object({
    action           = string
    protocol         = string
    source           = string
    source_port      = string
    destination      = string
    destination_port = string
    direction        = string
  }))
  default = []
}

variable "network_firewall_log_retention" {
  description = "Number of days to retain Network Firewall logs"
  type        = number
  default     = 90
}