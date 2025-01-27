# # modules/control_tower/guardrails.tf

# data "aws_region" "current" {}

# data "aws_organizations_organization" "main" {}

# # # Get the root OU first
# # data "aws_organizations_root" "main" {
# #   depends_on = [aws_organizations_organization.main]
# # }

# resource "aws_controltower_control" "required" {
#   for_each = toset([
#     "AWS-GR_EC2_VOLUME_INUSE_CHECK",
#     "AWS-GR_ENCRYPTED_VOLUMES",
#     "AWS-GR_RESTRICT_ROOT_USER",
#     "AWS-GR_IAM_USER_MFA_ENABLED",
#     "AWS-GR_AUDIT_BUCKET_ENCRYPTION_ENABLED"
#   ])

#   control_identifier = "arn:aws:controltower:${data.aws_region.current.name}::control/${each.key}"
#   target_identifier = aws_organizations_organizational_unit.infrastructure.id

#   parameters {
#     key   = "AllowedRegions"
#     value = jsonencode(["us-east-1"])
#   }

#     depends_on = [
#     aws_organizations_organizational_unit.infrastructure,
#     aws_organizations_organization.main
#   ]

# }

# # # Region restriction control
# # resource "aws_controltower_control" "region_restriction" {
# #   control_identifier = "arn:aws:controltower:${data.aws_region.current.name}::control/AWS-GR_REGION_RESTRICTION"
# #   target_identifier = data.aws_organizations_root.main.id

# #   parameters {
# #     key   = "AllowedRegions"
# #     value = jsonencode(var.target_regions)
# #   }

# #   depends_on = [
# #     aws_organizations_organization.main
# #   ]
# # }


# # # Service Control Policies
# # resource "aws_organizations_policy" "deny_root" {
# #   name = "DenyRootAccess"
# #   content = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [
# #       {
# #         Effect = "Deny"
# #         Action = "*"
# #         Resource = "*"
# #         Condition = {
# #           StringLike = {
# #             "aws:PrincipalArn": ["arn:aws:iam::*:root"]
# #           }
# #         }
# #       }
# #     ]
# #   })
# # }

# # resource "aws_organizations_policy" "require_mfa" {
# #   name = "RequireMFA"
# #   content = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [
# #       {
# #         Effect = "Deny"
# #         Action = "*"
# #         Resource = "*"
# #         Condition = {
# #           BoolIfExists = {
# #             "aws:MultiFactorAuthPresent": "false"
# #           }
# #         }
# #       }
# #     ]
# #   })
# # }