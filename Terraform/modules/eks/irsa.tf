# # modules/eks/irsa.tf

# # IRSA for Arbiters
# resource "aws_iam_role" "arbiters" {
#   name = "${local.name}-arbiters"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Principal = {
#           Federated = aws_iam_openid_connect_provider.eks.arn
#         }
#         Condition = {
#           StringEquals = {
#             "${aws_iam_openid_connect_provider.eks.url}:sub" : "system:serviceaccount:trading:arbiter-sa"
#           }
#         }
#       }
#     ]
#   })

#   tags = local.tags
# }

# # IRSA for Market Data Services
# resource "aws_iam_role" "market_data" {
#   name = "${local.name}-market-data"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Principal = {
#           Federated = aws_iam_openid_connect_provider.eks.arn
#         }
#         Condition = {
#           StringEquals = {
#             "${aws_iam_openid_connect_provider.eks.url}:sub" : "system:serviceaccount:trading:market-data-sa"
#           }
#         }
#       }
#     ]
#   })

#   tags = local.tags
# }

# # Add necessary policies
# resource "aws_iam_role_policy" "market_data_s3" {
#   name = "market-data-s3"
#   role = aws_iam_role.market_data.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:ListBucket"
#         ]
#         Resource = [
#           "arn:aws:s3:::${var.market_data_bucket}",
#           "arn:aws:s3:::${var.market_data_bucket}/*"
#         ]
#       }
#     ]
#   })
# }
