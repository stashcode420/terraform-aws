output "repository_urls" {
  description = "The URLs of the ECR repositories"
  value = {
    for repo in var.repository_names : repo => aws_ecr_repository.repositories[repo].repository_url
  }
}

output "repository_arns" {
  description = "The ARNs of the ECR repositories"
  value = {
    for repo in var.repository_names : repo => aws_ecr_repository.repositories[repo].arn
  }
}