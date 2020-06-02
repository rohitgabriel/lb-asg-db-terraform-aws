#####
# DB
#####
resource "random_password" "dbpass" {
  length  = 8
  special = false
}

resource "aws_db_subnet_group" "testapp_db_group" {
  name       = "${var.app_name}_db_group"
  subnet_ids = var.subnet_ids

  tags = {
    Name    = "${var.app_name}_db_group"
    Project = "${var.app_name}"
  }
}

resource "aws_db_instance" "testapp_db" {
  identifier                          = "${var.app_name}db"
  engine                              = var.db_engine
  engine_version                      = var.db_engine_version
  instance_class                      = var.db_instance_type
  allocated_storage                   = var.db_allocated_storage
  max_allocated_storage               = var.db_max_allocated_storage
  storage_type                        = "gp2"
  name                                = "app"
  username                            = "postgres"
  password                            = random_password.dbpass.result
  iam_database_authentication_enabled = true
  multi_az                            = true
  port                                = var.db_port
  vpc_security_group_ids              = var.vpc_security_group_ids
  maintenance_window                  = "Mon:00:00-Mon:03:00"
  backup_window                       = "03:00-06:00"
  backup_retention_period             = 0
  db_subnet_group_name                = aws_db_subnet_group.testapp_db_group.id
  deletion_protection                 = false
  tags = {
    project = "${var.app_name}"
  }
}