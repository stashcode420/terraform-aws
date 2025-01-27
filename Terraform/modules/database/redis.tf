# modules/database/redis.tf
resource "aws_elasticache_cluster" "redis" {
  cluster_id      = "${local.name}-redis"
  engine          = "redis"
  engine_version  = "7.0"
  node_type       = var.redis_node_type
  num_cache_nodes = 1
  port            = 6379

  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]
  parameter_group_name = aws_elasticache_parameter_group.redis.name

  maintenance_window = "sun:05:00-sun:06:00"
  snapshot_window    = "04:00-05:00"

  snapshot_retention_limit = var.backup_retention_period

  auto_minor_version_upgrade = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = local.tags
}

resource "aws_elasticache_parameter_group" "redis" {
  family = "redis7"
  name   = "${local.name}-redis-params"

  parameter {
    name  = "maxmemory-policy"
    value = "volatile-lru"
  }

  parameter {
    name  = "notify-keyspace-events"
    value = "Ex"
  }

  tags = local.tags
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${local.name}-redis-subnet"
  subnet_ids = var.private_subnet_ids

  tags = local.tags
}
