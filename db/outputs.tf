output "db_password" {
  description = "Database password"
  value       = random_string.dbpass.result
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.testapp_db.name
}

output "db_instance_endpoint" {
  description = "The database connection endpoint"
  value       = aws_db_instance.testapp_db.endpoint
}

output "arn" {
  description = "The database arn"
  value       = aws_db_instance.testapp_db.arn
}