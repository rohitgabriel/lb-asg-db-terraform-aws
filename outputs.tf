

output "elb_dns_name" {
  description = "DNS Name of the ELB"
  value       = aws_elb.clb.dns_name
}

# output "db_password" {
#   description = "Decoded database password"
#   value       = jsondecode(aws_secretsmanager_secret_version.TestAppCredentials3.secret_string)["password"]
# }