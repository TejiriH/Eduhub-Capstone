output "postgres_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "postgres_connection_string" {
  value = "postgresql://${var.db_master_username}:${var.db_master_password}@${aws_db_instance.postgres.endpoint}"
  sensitive = true
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.address
}

output "redis_port" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.port
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.analytics.name
}