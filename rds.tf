// RDS Terraform module to create multi AZ Postgres deployment
##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################


# #####
# # DB
# #####
# resource "random_string" "dbpass" {
#   length  = 8
#   special = false
# }

# module "db" {
#   source = "terraform-aws-modules/rds/aws"

#   identifier = "testapp-postgres"

#   engine                              = "postgres"
#   engine_version                      = "9.6.9"
#   instance_class                      = "db.t2.micro"
#   allocated_storage                   = 10
#   storage_encrypted                   = false
#   iam_database_authentication_enabled = true
#   multi_az                            = true

#   # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
#   name = "app"

#   # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
#   # "Error creating DB Instance: InvalidParameterValue: MasterUsername
#   # user cannot be used as it is a reserved word used by the engine"
#   username = "postgres"

#   # password = "${var.db_password}"
#   password = random_string.dbpass.result
#   port     = "5432"

#   vpc_security_group_ids = [data.aws_security_group.default.id]

#   maintenance_window = "Mon:00:00-Mon:03:00"
#   backup_window      = "03:00-06:00"

#   # disable backups to create DB faster
#   backup_retention_period = 0

#   tags = {
#     Owner       = "user"
#     Environment = "dev"
#   }

#   enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

#   # DB subnet group
#   subnet_ids = data.aws_subnet_ids.selected.ids

#   # DB parameter group
#   family = "postgres9.6"

#   # DB option group
#   major_engine_version = "9.6"

#   # Snapshot name upon DB deletion
#   #   final_snapshot_identifier = "demodb"

#   # Database Deletion Protection
#   deletion_protection = false
# }