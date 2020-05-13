# output "region" {
#   description = "AWS region"
#   value       = var.AWS_REGION
# }

output "this_db_instance_endpoint" {
  description = "The connection endpoint"
  value       = "${module.db.this_db_instance_endpoint}"
}

output "this_db_instance_name" {
  description = "The database name"
  value       = "${module.db.this_db_instance_name}"
}

# ELB DNS name
output "this_elb_dns_name" {
  description = "DNS Name of the ELB"
  value       = aws_elb.clb.dns_name
}

# output "db_password" {
#   value = jsondecode(data.aws_secretsmanager_secret_version.by-version-stage.secret_string)["password"]
# }