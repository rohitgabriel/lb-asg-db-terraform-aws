locals {
  app_name = "techtestapp"
}

// Create new VPC using module
# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "testappvpc"
#   cidr = "10.0.0.0/16"

#   azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#   enable_nat_gateway = true
#   enable_vpn_gateway = false

#   tags = {
#     app = "testapp"
#   }
# }
// VPC
resource "aws_vpc" "vpc_network_VPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    "Name" = "10.0.0.0/16 - ${local.app_name}"
  }
}

//Subnets
resource "aws_subnet" "vpc_network_SubnetAPublic" {
  vpc_id                  = aws_vpc.vpc_network_VPC.id
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-southeast-2a"

  tags = {
    "Name" = "${local.app_name}_A_Public"
  }
}

resource "aws_subnet" "vpc_network_SubnetBPublic" {
  vpc_id                  = aws_vpc.vpc_network_VPC.id
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-southeast-2b"

  tags = {
    "Name" = "${local.app_name}_B_Public"
  }
}

resource "aws_subnet" "vpc_network_SubnetCPublic" {
  vpc_id                  = aws_vpc.vpc_network_VPC.id
  cidr_block              = "10.0.103.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-southeast-2c"

  tags = {
    "Name" = "${local.app_name}_C_Public"
  }
}

resource "aws_subnet" "vpc_network_SubnetAPrivate" {
  vpc_id                  = aws_vpc.vpc_network_VPC.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "ap-southeast-2a"

  tags = {
    "Name" = "${local.app_name}_A_Private"
  }
}

resource "aws_subnet" "vpc_network_SubnetBPrivate" {
  vpc_id                  = aws_vpc.vpc_network_VPC.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "ap-southeast-2b"

  tags = {
    "Name" = "${local.app_name}_B_Private"
  }
}

resource "aws_subnet" "vpc_network_SubnetCPrivate" {
  vpc_id                  = aws_vpc.vpc_network_VPC.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "ap-southeast-2c"

  tags = {
    "Name" = "${local.app_name}_C_Private"
  }
}

//Internet gateway
resource "aws_internet_gateway" "vpc_network_internetgw" {
  vpc_id = aws_vpc.vpc_network_VPC.id

  tags = {
    Name = "${local.app_name}_igw"
  }
}

//NAT gateway
resource "aws_eip" "nat_A_Public" {
  vpc = true
  tags = {
    Name = "${local.app_name}_natgw_A_Public"
  }
}
resource "aws_eip" "nat_B_Public" {
  vpc = true
  tags = {
    Name = "${local.app_name}_natgw_B_Public"
  }
}
resource "aws_eip" "nat_C_Public" {
  vpc = true
  tags = {
    Name = "${local.app_name}_natgw_C_Public"
  }
}

resource "aws_nat_gateway" "nat_gw_A_Public" {
  allocation_id = aws_eip.nat_A_Public.id
  subnet_id     = aws_subnet.vpc_network_SubnetAPublic.id
  depends_on    = [aws_internet_gateway.vpc_network_internetgw]
  tags = {
    Name = "${local.app_name}_natgw_A_Public"
  }
}
resource "aws_nat_gateway" "nat_gw_B_Public" {
  allocation_id = aws_eip.nat_B_Public.id
  subnet_id     = aws_subnet.vpc_network_SubnetBPublic.id
  depends_on    = [aws_internet_gateway.vpc_network_internetgw]
  tags = {
    Name = "${local.app_name}_natgw_B_Public"
  }
}
resource "aws_nat_gateway" "nat_gw_C_Public" {
  allocation_id = aws_eip.nat_C_Public.id
  subnet_id     = aws_subnet.vpc_network_SubnetCPublic.id
  depends_on    = [aws_internet_gateway.vpc_network_internetgw]
  tags = {
    Name = "${local.app_name}_natgw_C_Public"
  }
}

//Route tables
resource "aws_route_table" "vpc_network_RouteTableAPublic" {
  vpc_id = aws_vpc.vpc_network_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_network_internetgw.id
  }

  tags = {
    Name = "${local.app_name}_A_Public"
  }
}

resource "aws_route_table" "vpc_network_RouteTableBPublic" {
  vpc_id = aws_vpc.vpc_network_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_network_internetgw.id
  }

  tags = {
    Name = "${local.app_name}_B_Public"
  }
}

resource "aws_route_table" "vpc_network_RouteTableCPublic" {
  vpc_id = aws_vpc.vpc_network_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_network_internetgw.id
  }

  tags = {
    Name = "${local.app_name}_C_Public"
  }
}

resource "aws_route_table" "vpc_network_RouteTableAPrivate" {
  vpc_id = aws_vpc.vpc_network_VPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_A_Public.id
  }

  tags = {
    Name = "${local.app_name}_A_Private"
  }
}

resource "aws_route_table" "vpc_network_RouteTableBPrivate" {
  vpc_id = aws_vpc.vpc_network_VPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_B_Public.id
  }

  tags = {
    Name = "${local.app_name}_B_Private"
  }
}

resource "aws_route_table" "vpc_network_RouteTableCPrivate" {
  vpc_id = aws_vpc.vpc_network_VPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_C_Public.id
  }

  tags = {
    Name = "${local.app_name}_C_Private"
  }
}

//route associations 
resource "aws_route_table_association" "vpc_network_RouteTableAPublic" {
  subnet_id      = aws_subnet.vpc_network_SubnetAPublic.id
  route_table_id = aws_route_table.vpc_network_RouteTableAPublic.id
}
resource "aws_route_table_association" "vpc_network_RouteTableBPublic" {
  subnet_id      = aws_subnet.vpc_network_SubnetBPublic.id
  route_table_id = aws_route_table.vpc_network_RouteTableBPublic.id
}
resource "aws_route_table_association" "vpc_network_RouteTableCPublic" {
  subnet_id      = aws_subnet.vpc_network_SubnetCPublic.id
  route_table_id = aws_route_table.vpc_network_RouteTableCPublic.id
}
resource "aws_route_table_association" "vpc_network_RouteTableAPrivate" {
  subnet_id      = aws_subnet.vpc_network_SubnetAPrivate.id
  route_table_id = aws_route_table.vpc_network_RouteTableAPrivate.id
}
resource "aws_route_table_association" "vpc_network_RouteTableBPrivate" {
  subnet_id      = aws_subnet.vpc_network_SubnetBPrivate.id
  route_table_id = aws_route_table.vpc_network_RouteTableBPrivate.id
}
resource "aws_route_table_association" "vpc_network_RouteTableCPrivate" {
  subnet_id      = aws_subnet.vpc_network_SubnetCPrivate.id
  route_table_id = aws_route_table.vpc_network_RouteTableCPrivate.id
}

// Create Security group to allow egress traffic
data "aws_subnet_ids" "all" {
  vpc_id     = aws_vpc.vpc_network_VPC.id
  depends_on = [aws_subnet.vpc_network_SubnetCPrivate]
}

data "aws_subnet_ids" "privatesubnets" {
  vpc_id     = aws_vpc.vpc_network_VPC.id
  depends_on = [aws_subnet.vpc_network_SubnetCPrivate]
  filter {
    name   = "tag:Name"
    values = ["*Private"]
  }
}

data "aws_subnet_ids" "publicsubnets" {
  vpc_id     = aws_vpc.vpc_network_VPC.id
  depends_on = [aws_subnet.vpc_network_SubnetCPublic]
  filter {
    name   = "tag:Name"
    values = ["*Public"]
  }
}

resource "aws_security_group" "internet" {
  vpc_id      = aws_vpc.vpc_network_VPC.id
  name        = "testapp_egress_sg"
  description = "security group to allow all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    project = "testapp"
  }
}

resource "aws_security_group" "public" {

  vpc_id      = aws_vpc.vpc_network_VPC.id
  name        = "testapp_lb"
  description = "security group to allow inbound traffic on port 3000 from internet"
  depends_on  = [aws_security_group.private]
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.private.id]
  }
  tags = {
    project = "testapp"
  }
}

// Create Security group to allow ingress traffic to nodejs app 
resource "aws_security_group" "private" {

  vpc_id      = aws_vpc.vpc_network_VPC.id
  name        = "testapp_ingress_nodejs"
  description = "security group to allow inbound traffic on port 3000 from elb"
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.vpc_network_SubnetAPublic.cidr_block, aws_subnet.vpc_network_SubnetBPublic.cidr_block, aws_subnet.vpc_network_SubnetCPublic.cidr_block]
  }
  tags = {
    project = "testapp"
  }
}

// Create Security group to allow ingress traffic to nodejs app 
resource "aws_security_group" "postgresdb" {
  vpc_id      = aws_vpc.vpc_network_VPC.id
  name        = "testapp_ingress_postgresdb"
  description = "security group that allows ssh and all egress traffic"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.vpc_network_SubnetAPrivate.cidr_block, aws_subnet.vpc_network_SubnetBPrivate.cidr_block, aws_subnet.vpc_network_SubnetCPrivate.cidr_block]
  }
  tags = {
    project = "testapp"
  }
}

# Create a new load balancer
resource "aws_elb" "clb" {
  name = "elb-techtest5"
  # availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]


  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 3000
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:3000/"
    interval            = 30
  }
  # instances                   = []
  subnets                     = data.aws_subnet_ids.publicsubnets.ids
  security_groups             = [aws_security_group.public.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    project = "testapp"
  }
}

######
# ELB
######
# module "elb" {
#   source = "terraform-aws-modules/elb/aws"

#   name = "elb-techtest4"

#   subnets         = data.aws_subnet_ids.publicsubnets.ids
#   security_groups = [aws_security_group.public.id]
#   internal        = false

#   listener = [
#     {
#       instance_port     = "3000"
#       instance_protocol = "HTTP"
#       lb_port           = "3000"
#       lb_protocol       = "HTTP"
#     },
#   ]

#   health_check = {
#     target              = "HTTP:3000/"
#     interval            = 30
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 5
#   }

#   tags = {
#     project = "testapp"
#   }
# }

#####
# DB
#####
resource "random_string" "dbpass" {
  length  = 8
  special = false
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "testapp-postgres"

  engine                              = "postgres"
  engine_version                      = "9.6.9"
  instance_class                      = "db.t2.micro"
  allocated_storage                   = 10
  storage_encrypted                   = false
  iam_database_authentication_enabled = true
  multi_az                            = true
  name                                = "app"
  username                            = "postgres"
  password                            = random_string.dbpass.result
  port                                = "5432"
  vpc_security_group_ids              = [aws_security_group.postgresdb.id]
  maintenance_window                  = "Mon:00:00-Mon:03:00"
  backup_window                       = "03:00-06:00"
  backup_retention_period             = 0
  tags = {
    project = "testapp"
  }
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  subnet_ids                      = data.aws_subnet_ids.privatesubnets.ids
  family                          = "postgres9.6"
  major_engine_version            = "9.6"
  deletion_protection             = false
}


// Create a new secret with the password passed in as variable, this is set as the DB password 
resource "aws_secretsmanager_secret" "TestAppSecret2" {
  name        = "dev2/testappdatabase1"
  description = "postgres credentials"
  #   rotation_rules {
  #     automatically_after_days = 7
  #   }
}

resource "aws_secretsmanager_secret_version" "TestAppCredentials2" {
  secret_id     = aws_secretsmanager_secret.TestAppSecret2.id
  secret_string = "{\"username\":\"postgres\",\"password\":\"${random_string.dbpass.result}\"}"
}

# data "aws_secretsmanager_secret_version" "by-version-stage" {
#   secret_id  = aws_secretsmanager_secret.TestAppSecret2.id
#   depends_on = [module.db]
# }

// Create Launch Configuration and Auto Scaling group 




# data "aws_security_group" "default" {
#   vpc_id     = module.vpc.vpc_id
#   name       = "sg_demo"
#   depends_on = [module.vpc]
# }

data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
locals {
  json_data = jsondecode(aws_secretsmanager_secret_version.TestAppCredentials2.secret_string)["password"]
}
######
# Launch configuration
######
resource "aws_launch_configuration" "this" {
  name_prefix = "testapp-launch-configuration-"
  image_id    = data.aws_ami.latest_ubuntu.id
  #image_id       = "ami-02a599eb01e3b3c5b"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.private.id, aws_security_group.internet.id]
  // Use the file content if that is 
  # user_data       = file("userdata.sh")
  user_data = <<-EOT
    #!/bin/bash
    apt-get update -y
    snap install --classic go
    apt-get install jq -y
    cp /snap/bin/go /usr/local/bin/
    apt-get install go-dep -y
    cd /tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    apt install unzip -y
    unzip awscliv2.zip
    ./aws/install
    aws s3 cp s3://eittestappbucket1/dist ~/application --recursive
    cd ~/application
    chmod 755 ./TechTestApp
    sed -i '/ListenHost/c\"ListenHost" = "0.0.0.0"' conf.toml
    aws rds describe-db-instances --db-instance-identifier testapp-postgres > /tmp/dbdetails.txt
    x=$(aws rds describe-db-instances --db-instance-identifier testapp-postgres| jq '.DBInstances[0].Endpoint.Address')
    sed -i "s/\"localhost\"/$x/g" conf.toml
    sed -i '/DbPassword/c\\"DbPassword\" = \"${local.json_data}\"' conf.toml
    ./TechTestApp updatedb -s
    ./TechTestApp serve
  EOT
  key_name  = "postgrestest"
  #iam_instance_profile = "postgres-secret-read"
  iam_instance_profile = aws_iam_instance_profile.test_profile.name

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [module.db]
}
######
# Autoscaling group
######
module "demo_asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name                 = "testapp-asg-instance"
  launch_configuration = aws_launch_configuration.this.name # Use the existing launch configuration
  create_lc            = false                              # disables creation of launch configuration
  #lc_name = "demo-lc"

  image_id = "ami-02a599eb01e3b3c5b"
  #image_id        = data.aws_ami.amazon_linux.id
  #image_id        = var.AMI_ID
  instance_type                = "t2.micro"
  security_groups              = [aws_security_group.internet.id]
  load_balancers               = [aws_elb.clb.id]
  associate_public_ip_address  = true
  key_name                     = "postgrestest"
  recreate_asg_when_lc_changes = true

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "demo-asg"
  vpc_zone_identifier       = data.aws_subnet_ids.privatesubnets.ids
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 3
  desired_capacity          = 0
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Project"
      value               = "testapp"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "testapp"
      propagate_at_launch = true
    },
  ]
}

