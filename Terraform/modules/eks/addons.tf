# modules/eks/addons.tf
resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "vpc-cni"
  addon_version            = "v1.12.6-eksbuild.2" # Update version as needed
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = aws_iam_role.vpc_cni.arn

  tags = local.tags
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.main.name
  addon_name        = "kube-proxy"
  addon_version     = "v1.27.1-eksbuild.1" # Update version as needed
  resolve_conflicts = "OVERWRITE"

  tags = local.tags
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.main.name
  addon_name        = "coredns"
  addon_version     = "v1.10.1-eksbuild.1" # Update version as needed
  resolve_conflicts = "OVERWRITE"

  tags = local.tags
}

# Cluster Autoscaler
resource "helm_release" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.29.0" # Update version as needed

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.main.name
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler[0].arn
  }
}

# Prometheus and Grafana
resource "helm_release" "prometheus" {
  count = var.enable_prometheus ? 1 : 0

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  version    = "45.7.1" # Update version as needed

  values = [
    file("${path.module}/files/prometheus-values.yaml")
  ]
}
