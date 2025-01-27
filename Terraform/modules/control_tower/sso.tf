# modules/control_tower/sso.tf

# # Get SSO Instance
# data "aws_ssoadmin_instances" "main" {}

# Create Identity Store Groups
resource "aws_identitystore_group" "developer" {
  for_each = { for group in var.developer_groups : group.name => group }

  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
  display_name     = each.value.name
  description      = each.value.description
}

# Create Permission Sets
resource "aws_ssoadmin_permission_set" "developer" {
  for_each = { for group in var.developer_groups : group.name => group }

  name             = each.value.name
  description      = each.value.description
  instance_arn     = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  session_duration = "PT8H"
}

# Attach Managed Policies to Permission Sets
resource "aws_ssoadmin_managed_policy_attachment" "developer_permissions" {
  for_each = { for group in var.developer_groups : group.name => group }

  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  permission_set_arn = aws_ssoadmin_permission_set.developer[each.key].arn
}

# Assign Permission Sets to Groups
resource "aws_ssoadmin_account_assignment" "developer" {
  for_each = { for group in var.developer_groups : group.name => group }

  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.developer[each.key].arn

  principal_id   = aws_identitystore_group.developer[each.key].group_id
  principal_type = "GROUP"

  target_id   = var.aws_ssoadmin_account_assignment
  target_type = "AWS_ACCOUNT"
}

# Create Users in Identity Store
resource "aws_identitystore_user" "developer_users" {
  for_each = { for user in flatten([
    for group in var.developer_groups : [
      for username in group.users : {
        group = group.name
        username = username
      }
    ]
  ]) : "${user.group}-${user.username}" => user }

  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
  
  user_name = each.value.username
  display_name = each.value.username

  name {
    given_name  = split("@", each.value.username)[0]
    family_name = "Developer"
  }

  emails {
    value = each.value.username
    primary = true
  }
}

# Assign Users to Groups
resource "aws_identitystore_group_membership" "developer_memberships" {
  for_each = { for user in flatten([
    for group in var.developer_groups : [
      for username in group.users : {
        group = group.name
        username = username
      }
    ]
  ]) : "${user.group}-${user.username}" => user }

  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
  group_id         = aws_identitystore_group.developer[each.value.group].group_id
  member_id        = aws_identitystore_user.developer_users["${each.value.group}-${each.value.username}"].user_id
}