output "db_password" {
  description = "Database password"
  value       = random_password.dbpass.result
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.testapp_db.name
}

output "db_instance_endpoint" {
  description = "The database connection endpoint"
  value       = aws_db_instance.testapp_db.endpoint
}

output "db_instance_address" {
  description = "The database hostname"
  value       = aws_db_instance.testapp_db.address
}

output "arn" {
  description = "The database arn"
  value       = aws_db_instance.testapp_db.arn
}