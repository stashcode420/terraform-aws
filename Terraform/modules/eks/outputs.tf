# modules/eks/outputs.tf

output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster API server"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "The security group ID for the EKS cluster"
  value       = aws_security_group.cluster.id
}

# output "node_security_group_id" {
#   description = "The security group ID for the EKS node groups"
#   value       = aws_security_group.nodes.id
# }

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by the EKS service"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "node_groups" {
  description = "Map of EKS managed node groups"
  value       = aws_eks_node_group.main
}

output "vpc_config" {
  description = "VPC configuration details"
  value = {
    vpc_id     = data.aws_vpc.existing.id
    subnet_ids = data.aws_subnets.private.ids
    subnet_details = {
      for subnet_id, subnet in data.aws_subnet.private : subnet_id => {
        cidr_block = subnet.cidr_block
        az         = subnet.availability_zone
        tags       = subnet.tags
      }
    }
  }
}