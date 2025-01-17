# modules/monitoring/grafana.tf
resource "aws_grafana_workspace" "main" {
  name                     = "${local.name}-grafana"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana.arn

  data_sources = ["PROMETHEUS", "CLOUDWATCH", "OPENSEARCH"]

  vpc_configuration {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.grafana.id]
  }

  tags = local.tags
}

resource "aws_grafana_role_association" "admin" {
  role         = "ADMIN"
  group_ids    = var.admin_group_ids
  workspace_id = aws_grafana_workspace.main.id
}
