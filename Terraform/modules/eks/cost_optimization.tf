# modules/eks/cost_optimization.tf

resource "helm_release" "kubecost" {
  name       = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  namespace  = "kubecost"
  version    = "1.96.0"

  set {
    name  = "kubecostToken"
    value = "none"
  }

  set {
    name  = "prometheus.nodeExporter.enabled"
    value = "true"
  }
}

resource "aws_lambda_function" "cost_optimizer" {
  filename      = "${path.module}/functions/cost-optimizer.zip"
  function_name = "${local.name}-cost-optimizer"
  role          = aws_iam_role.cost_optimizer.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"

  environment {
    variables = {
      CLUSTER_NAME = aws_eks_cluster.main.name
      THRESHOLD    = "0.7"
    }
  }
}
