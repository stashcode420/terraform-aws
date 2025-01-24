# modules/eks/monitoring.tf

# Prometheus and Grafana Stack
# modules/eks/monitoring.tf
# Update the prometheus_stack helm release

resource "helm_release" "prometheus_stack" {
  count = var.enable_monitoring ? 1 : 0

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  # namespace  = kubernetes_namespace.monitoring[0].metadata[0].name
  namespace  = "monitoring"
  
  version    = var.prometheus_stack_version

  values = [
    templatefile("${path.module}/templates/prometheus-values.yaml", {
      retention_days = var.prometheus_retention_days
      storage_class = var.prometheus_storage_class
      grafana_domain = var.grafana_domain
      admin_password = var.grafana_admin_password
    })
  ]

  depends_on = [aws_eks_node_group.main]
}

# # CloudWatch Container Insights
# resource "aws_cloudwatch_log_group" "containers" {
#   count             = var.enable_container_insights ? 1 : 0
#   name              = "/aws/containerinsights/${local.name}/performance"
#   retention_in_days = var.log_retention_days
#   kms_key_id       = aws_kms_key.cloudwatch.arn

#   tags = local.tags
# }

# # Fluent Bit for Log Aggregation
# resource "helm_release" "fluent_bit" {
#   count = var.enable_container_insights ? 1 : 0

#   name       = "fluent-bit"
#   repository = "https://fluent.github.io/helm-charts"
#   chart      = "fluent-bit"
#   namespace  = kubernetes_namespace.logging[0].metadata[0].name
#   version    = var.fluent_bit_version

#   values = [
#     templatefile("${path.module}/templates/fluent-bit-values.yaml", {
#       log_group_name = aws_cloudwatch_log_group.containers[0].name
#       region        = data.aws_region.current.name
#       cluster_name  = local.name
#     })
#   ]

#   depends_on = [aws_eks_node_group.main]
# }

# modules/eks/monitoring.tf

# resource "kubernetes_namespace" "monitoring" {
#   count = var.enable_monitoring ? 1 : 0

#   depends_on = [aws_eks_cluster.main]

#   metadata {
#     name = "monitoring"
#     labels = {
#       name = "monitoring"
#     }
#   }
# }

# resource "kubernetes_namespace" "logging" {
#   count = var.enable_logging ? 1 : 0

#   depends_on = [aws_eks_cluster.main]

#   metadata {
#     name = "logging"
#     labels = {
#       name = "logging"
#     }
#   }
# }
