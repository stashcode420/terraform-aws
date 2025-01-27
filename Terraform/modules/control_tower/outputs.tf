# # modules/control_tower/outputs.tf
# output "organization_id" {
#   description = "The ID of the AWS Organization"
#   value       = aws_organizations_organization.main.id
# }

# output "organizational_units" {
#   description = "Map of created Organizational Units"
#   value = {
#     environments   = aws_organizations_organizational_unit.environments.id
#     # security      = aws_organizations_organizational_unit.security.id
#     infrastructure = aws_organizations_organizational_unit.infrastructure.id
#   }
# }

# output "environment_accounts" {
#   description = "Map of created environment accounts"
#   value = {
#     for account in aws_organizations_account.environments : account.name => {
#       id    = account.id
#       arn   = account.arn
#       email = account.email
#     }
#   }
# }

# output "core_accounts" {
#   description = "Map of core accounts"
#   value = {
#     audit = {
#       id    = aws_organizations_account.audit.id
#       arn   = aws_organizations_account.audit.arn
#       email = aws_organizations_account.audit.email
#     }
#     log_archive = {
#       id    = aws_organizations_account.log_archive.id
#       arn   = aws_organizations_account.log_archive.arn
#       email = aws_organizations_account.log_archive.email
#     }
#   }
# }

# output "developer_roles" {
#   description = "Map of created developer roles"
#   value = {
#     for role in aws_iam_role.developer : role.name => {
#       arn  = role.arn
#       name = role.name
#     }
#   }
# }

# output "sso_instance_arn" {
#   description = "ARN of the AWS SSO instance"
#   value       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
# }