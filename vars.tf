variable "AWS_REGION" {
  default     = "ap-southeast-2"
  description = "Set the AWS region"
  type        = string
}
variable "instance_type" {
  default     = "t2.micro"
  description = "Set the EC2 Instance type"
  type        = string
}

variable "db_instance_type" {
  default     = "db.t2.micro"
  description = "Set the RDS Instance type"
  type        = string
}

# variable key_name {
#   default = "postgrestest"
# }
# variable db_password {
#     description = "Set a db password of more than 8 characters"
# }