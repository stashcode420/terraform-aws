# # modules/control_tower/iam.tf
# # IAM Role for Control Tower Access
# resource "aws_iam_role" "control_tower_admin" {
#   name = "ControlTowerAdmin"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "controltower.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = local.tags
# }

# # Developer Role Policies
# resource "aws_iam_role" "developer" {
#   for_each = { for group in var.developer_groups : group.name => group }

#   name = "Developer-${each.key}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "sso.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = merge(local.tags, {
#     Group = each.key
#   })
# }

# # Developer Permission Boundaries
# resource "aws_iam_policy" "developer_boundary" {
#   for_each = { for group in var.developer_groups : group.name => group }

#   name = "DeveloperBoundary-${each.key}"
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:*",
#           "ec2:*",
#           "rds:*",
#           "elasticache:*",
#           "eks:*",
#           "ecr:*"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Deny"
#         Action = [
#           "organizations:*",
#           "iam:CreateUser",
#           "iam:DeleteUser",
#           "iam:CreateRole",
#           "iam:DeleteRole"
#         ]
#         Resource = "*"
#       }
#     ]
#   })

#   tags = merge(local.tags, {
#     Group = each.key
#   })
# }

# modules/control_tower/iam.tf

# AWSControlTowerAdmin role
resource "aws_iam_role" "control_tower_admin" {
  name = "AWSControlTowerAdmin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "controltower.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

# Attach required policies to AWSControlTowerAdmin role
resource "aws_iam_role_policy_attachment" "control_tower_admin_policy" {
  role       = aws_iam_role.control_tower_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Service-linked role for Control Tower
resource "aws_iam_service_linked_role" "control_tower" {
  aws_service_name = "controltower.amazonaws.com"
  description      = "Service-linked role for AWS Control Tower"
}