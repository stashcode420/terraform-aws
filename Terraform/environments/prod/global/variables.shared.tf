# environments/global/variables.shared.tf
variable "project" {
  description = "Project name"
  type        = string
  default     = "trading-platform"
}

variable "organization" {
  description = "Organization name"
  type        = string
  default     = "trading-org"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Project   = "trading-platform"
    ManagedBy = "terraform"
  }
}
