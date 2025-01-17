# infrastructure/modules/networking/outputs.tf

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs"
  value       = module.vpc.private_subnets
}

output "private_db_subnet_ids" {
  description = "Private database subnet IDs"
  value       = module.vpc.database_subnets
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.main.id
}

output "nat_public_ips" {
  description = "NAT Gateway public IPs"
  value       = module.vpc.nat_public_ips
}

# infrastructure/modules/networking/outputs.tf
# Additional outputs
output "vpc_endpoint_ids" {
  description = "Map of VPC Endpoint IDs"
  value       = module.vpc_endpoints.endpoints
}

output "vpn_gateway_id" {
  description = "VPN Gateway ID"
  value       = try(aws_vpn_gateway.main[0].id, null)
}

output "network_firewall_id" {
  description = "Network Firewall ID"
  value       = try(aws_networkfirewall_firewall.main[0].id, null)
}
