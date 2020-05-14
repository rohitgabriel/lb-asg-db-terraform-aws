output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.testapp_db.name
}

output "db_instance_endpoint" {
  description = "The database connection endpoint"
  value       = aws_db_instance.testapp_db.endpoint
}

output "elb_dns_name" {
  description = "DNS Name of the ELB"
  value       = aws_elb.clb.dns_name
}

output "db_password" {
  description = "Decoded databasse password"
  value       = jsondecode(aws_secretsmanager_secret_version.TestAppCredentials2.secret_string)["password"]
}