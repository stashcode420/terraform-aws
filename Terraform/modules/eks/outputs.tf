# modules/eks/outputs.tf
output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID for the cluster control plane"
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "Security group ID for the cluster nodes"
  value       = aws_security_group.nodes.id
}

output "cluster_iam_role_name" {
  description = "IAM role name for the cluster"
  value       = aws_iam_role.cluster.name
}

output "node_groups" {
  description = "Map of node groups created"
  value       = aws_eks_node_group.main
}
