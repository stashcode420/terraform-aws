# # modules/eks/logging.tf

# resource "aws_cloudwatch_log_group" "applications" {
#   name              = "/aws/eks/${local.name}/applications"
#   retention_in_days = 90

#   tags = local.tags
# }

# # Fluent Bit configuration for log shipping
# resource "helm_release" "fluent_bit" {
#   name       = "fluent-bit"
#   repository = "https://fluent.github.io/helm-charts"
#   chart      = "fluent-bit"
#   namespace  = "logging"
#   version    = "0.20.0"

#   values = [
#     templatefile("${path.module}/templates/fluent-bit-values.yaml", {
#       log_group_name = aws_cloudwatch_log_group.applications.name
#       region         = var.region
#       cluster_name   = aws_eks_cluster.main.name
#     })
#   ]

#   depends_on = [
#     kubernetes_namespace.logging
#   ]
# }

# resource "kubernetes_namespace" "logging" {
#   metadata {
#     name = "logging"
#   }
# }
