# modules/dr/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "primary_region" {
  description = "Primary region"
  type        = string
}

variable "dr_region" {
  description = "DR region"
  type        = string
}

variable "primary_vpc_id" {
  description = "Primary VPC ID"
  type        = string
}

variable "dr_vpc_id" {
  description = "DR VPC ID"
  type        = string
}

variable "enable_cross_region_replication" {
  description = "Enable cross-region replication"
  type        = bool
  default     = true
}
