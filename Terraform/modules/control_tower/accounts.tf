# # modules/control_tower/accounts.tf
# # Log Archive Account
# resource "aws_organizations_account" "log_archive" {
#   name      = "LogArchive"
#   email     = var.log_archive_account_email
#   parent_id = aws_organizations_organizational_unit.security.id

#   role_name = "OrganizationAccountAccessRole"
  
#   tags = {
#     Type = "LogArchive"
#   }
# }

# # Audit Account
# resource "aws_organizations_account" "audit" {
#   name      = "Audit"
#   email     = var.audit_account_email
#   parent_id = aws_organizations_organizational_unit.security.id

#   role_name = "OrganizationAccountAccessRole"
  
#   tags = {
#     Type = "Audit"
#   }
# }

# # Environment Accounts
# resource "aws_organizations_account" "environments" {
#   for_each = { for env in var.environments : env.name => env }

#   name      = each.value.name
#   email     = each.value.email
#   parent_id = aws_organizations_organizational_unit.environments.id

#   role_name = "OrganizationAccountAccessRole"
  
#   tags = {
#     Environment = each.value.name
#   }
# }