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
  default     = "9.6.11"
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

variable "vpc_security_group_ids" {}
variable "subnet_ids" {}

variable "app_name" {
  type        = string
  default     = "techtestapp"
  description = "Name of the application"
}
