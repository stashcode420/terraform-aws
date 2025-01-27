# modules/security/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "enable_shield_advanced" {
  description = "Enable AWS Shield Advanced"
  type        = bool
  default     = true
}

variable "enable_waf" {
  description = "Enable WAF"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP CIDR ranges"
  type        = list(string)
  default     = []
}

variable "trading_api_domain" {
  description = "Domain name for the trading API"
  type        = string
}
