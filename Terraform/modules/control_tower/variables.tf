# modules/control_tower/variables.tf
variable "organization_name" {
  description = "Name of the AWS Organization"
  type        = string
}

variable "master_account_email" {
  description = "Email address for the master account"
  type        = string
}

variable "log_archive_account_email" {
  description = "Email address for the log archive account"
  type        = string
}

variable "audit_account_email" {
  description = "Email address for the audit account"
  type        = string
}

variable "region" {
  description = "Primary AWS region for Control Tower"
  type        = string
  default     = "us-east-1"
}

variable "environments" {
  description = "List of environments to create"
  type = list(object({
    name  = string
    email = string
  }))
}

variable "developer_groups" {
  description = "Developer groups configuration"
  type = list(object({
    name        = string
    description = string
    users       = list(string)
    permissions = list(string)
  }))
}

variable "aws_ssoadmin_account_assignment" {
  description = "aws_ssoadmin_account_assignment"
  type = string
}

variable "target_regions" {
  description = "List of regions where Control Tower will be deployed"
  type        = list(string)
  default     = ["us-east-1"]
}

variable "enable_guardrails" {
  description = "Enable Control Tower guardrails"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable Control Tower logging"
  type        = bool
  default     = true
}