# # modules/control_tower/organizations.tf
# resource "aws_organizations_organization" "main" {
#   feature_set = "ALL"
  
#   enabled_policy_types = [
#     "SERVICE_CONTROL_POLICY",
#     "TAG_POLICY",
#     "BACKUP_POLICY",
#     "AISERVICES_OPT_OUT_POLICY"
#   ]

#   aws_service_access_principals = [
#     "sso.amazonaws.com",
#     "controltower.amazonaws.com",
#     "config.amazonaws.com",
#     "cloudtrail.amazonaws.com",
#     "ram.amazonaws.com",
#     "guardduty.amazonaws.com",
#     "securityhub.amazonaws.com"
#   ]
# }

# # Create Organizational Units
# resource "aws_organizations_organizational_unit" "environments" {
#   name      = "Environments"
#   parent_id = aws_organizations_organization.main.roots[0].id
# }

# resource "aws_organizations_organizational_unit" "security" {
#   name      = "Security"
#   parent_id = aws_organizations_organization.main.roots[0].id
# }

# resource "aws_organizations_organizational_unit" "infrastructure" {
#   name      = "Infrastructure"
#   parent_id = aws_organizations_organization.main.roots[0].id
# }