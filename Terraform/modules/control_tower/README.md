# AWS Control Tower Terraform Module

This module sets up AWS Control Tower with a multi-account strategy and developer access management.

## Features

- Multi-account AWS Organization setup
- AWS Control Tower landing zone
- SSO configuration for developer access
- Security guardrails and compliance policies
- Developer permission boundaries
- Centralized logging and audit

## Usage

```hcl
module "control_tower" {
  source = "./modules/control_tower"

  organization_name          = "MyCompany"
  master_account_email      = "master@company.com"
  log_archive_account_email = "logs@company.com"
  audit_account_email       = "audit@company.com"

  environments = [
    {
      name  = "Development"
      email = "dev@company.com"
    },
    {
      name  = "Staging"
      email = "staging@company.com"
    },
    {
      name  = "Production"
      email = "prod@company.com"
    }
  ]

  developer_groups = [
    {
      name        = "JuniorDevelopers"
      description = "Junior Developer Group"
      users       = ["dev1@company.com"]
      permissions = ["ReadOnlyAccess"]
    }
  ]
}