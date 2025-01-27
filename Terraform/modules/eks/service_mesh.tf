# # modules/eks/service_mesh.tf

# resource "aws_appmesh_mesh" "trading" {
#   name = "${local.name}-mesh"

#   spec {
#     egress_filter {
#       type = "ALLOW_ALL"
#     }
#   }

#   tags = local.tags
# }

# # App Mesh Controller
# resource "helm_release" "appmesh_controller" {
#   name       = "appmesh-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "appmesh-controller"
#   namespace  = "appmesh-system"
#   version    = "1.12.0"

#   set {
#     name  = "region"
#     value = var.region
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.appmesh_controller.arn
#   }
# }
