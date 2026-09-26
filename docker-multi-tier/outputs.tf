output "postgres_connection_string" {
  description = "The connection string for the new db_A database."
  value       = "postgresql://db_a_user:${var.app_db_password}@${var.postgres_host}:5432/db_A"
  sensitive   = true
}

output "redis_connection_info" {
  description = "Instructions to connect to Redis."
  value       = "redis-cli -h ${var.postgres_host} -p 6379 --user ${var.redis_user} --pass <password>"
}