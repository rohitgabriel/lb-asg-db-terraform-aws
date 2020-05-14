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

variable "db_port" {
  default     = "5432"
  description = "Set the RDS port number"
  type        = number
}

variable "db_engine" {
  default     = "postgres"
  description = "Set the RDS engine type"
  type        = string
}

variable "db_engine_version" {
  default     = "9.6.9"
  description = "Set the RDS engine version"
  type        = string
}

variable "db_allocated_storage" {
  default     = 10
  description = "Set the db storage size"
  type        = number
}

variable "db_max_allocated_storage" {
  default     = 20
  description = "Set the max db storage size -- uses auto scaling feature"
  type        = number
}

variable "ebs_device_name" {
  default     = "/dev/xvdz"
  description = "Set the EBS device name"
  type        = string
}

variable "ebs_volume_type" {
  default     = "gp2"
  description = "Set the EBS volume type"
  type        = string
}

variable "ebs_volume_size" {
  default     = "50"
  description = "Set the EBS volume size in GB"
  type        = string
}

variable "lb_port" {
  default     = 3000
  description = "Set the EBS volume size in GB"
  type        = number
}

variable "app_port" {
  default     = 3000
  description = "Set the EBS volume size in GB"
  type        = number
}

# variable key_name {
#   default = "postgrestest"
# }
