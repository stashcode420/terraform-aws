# modules/dr/outputs.tf
output "failover_state_machine_arn" {
  description = "ARN of the DR failover state machine"
  value       = aws_sfn_state_machine.dr_failover.arn
}

output "health_check_id" {
  description = "ID of the primary region health check"
  value       = aws_route53_health_check.primary.id
}

output "vpc_peering_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.primary_dr.id
}
