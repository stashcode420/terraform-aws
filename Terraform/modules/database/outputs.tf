# modules/database/outputs.tf
output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.application.endpoint
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.application.arn
}

output "redis_endpoint" {
  description = "The endpoint for the Redis cluster"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "The port for the Redis cluster"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].port
}

output "db_security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.database.id
}

output "redis_security_group_id" {
  description = "The ID of the Redis security group"
  value       = aws_security_group.redis.id
}

output "db_secret_arn" {
  description = "The ARN of the database credentials secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
}
