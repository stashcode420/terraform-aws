# modules/control_tower/main.tf
locals {
  name   = var.organization_name
  region = var.region

  tags = {
    Organization = var.organization_name
    ManagedBy   = "Terraform"
  }
}

data "aws_ssoadmin_instances" "main" {}

# data "aws_identitystore_group" "developer_groups" {
#   for_each = { for group in var.developer_groups : group.name => group }

#   identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
  
#   filter {
#     attribute_path  = "DisplayName"
#     attribute_value = each.value.name
#   }
# }