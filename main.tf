provider "aws" {
  version = ">= 2.53"
  region  = var.AWS_REGION
}

terraform {
  required_version = ">= 0.12"
}

locals {
  app_name = "techtestapp"
  app_name2 = "testapp"
}
#####
# VPC
#####
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

#####
# Subnets
#####
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

#####
# Route Tables
#####
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

#####
# Route Assocations
#####
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

#####
# Subnet data
#####
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

#####
# IAM
#####
// Create new IAM Role with s3, secretsmanager and RDS access
resource "aws_iam_role" "ec2_s3_secretmanager_role" {
  name               = "s3-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  // assume_role_policy = "${file("assumerolepolicy.json")}"
}

resource "aws_iam_policy" "policy" {
  name        = "${local.app_name2}_policy"
  description = "${local.app_name2} policy"
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": "${aws_secretsmanager_secret.TestAppSecret2.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetRandomPassword",
                "secretsmanager:ListSecrets"
            ],
            "Resource": "${aws_secretsmanager_secret_version.TestAppCredentials2.arn}"
        },
        {
            "Effect": "Allow",
            "Action": "rds:*",
            "Resource": "${aws_db_instance.testapp_db.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetAccessPoint",
                "s3:GetLifecycleConfiguration",
                "s3:GetBucketTagging",
                "s3:GetInventoryConfiguration",
                "s3:GetObjectVersionTagging",
                "s3:ListBucketVersions",
                "s3:GetBucketLogging",
                "s3:ListBucket",
                "s3:GetAccelerateConfiguration",
                "s3:GetBucketPolicy",
                "s3:GetObjectVersionTorrent",
                "s3:GetObjectAcl",
                "s3:GetEncryptionConfiguration",
                "s3:GetBucketObjectLockConfiguration",
                "s3:GetBucketRequestPayment",
                "s3:GetAccessPointPolicyStatus",
                "s3:GetObjectVersionAcl",
                "s3:GetObjectTagging",
                "s3:GetMetricsConfiguration",
                "s3:HeadBucket",
                "s3:GetBucketPublicAccessBlock",
                "s3:GetBucketPolicyStatus",
                "s3:ListBucketMultipartUploads",
                "s3:GetObjectRetention",
                "s3:GetBucketWebsite",
                "s3:ListAccessPoints",
                "s3:ListJobs",
                "s3:GetBucketVersioning",
                "s3:GetBucketAcl",
                "s3:GetObjectLegalHold",
                "s3:GetBucketNotification",
                "s3:GetReplicationConfiguration",
                "s3:ListMultipartUploadParts",
                "s3:GetObject",
                "s3:GetObjectTorrent",
                "s3:GetAccountPublicAccessBlock",
                "s3:ListAllMyBuckets",
                "s3:DescribeJob",
                "s3:GetBucketCORS",
                "s3:GetAnalyticsConfiguration",
                "s3:GetObjectVersionForReplication",
                "s3:GetBucketLocation",
                "s3:GetAccessPointPolicy",
                "s3:GetObjectVersion"
            ],
            "Resource": "*"
        }
    ]
  }
  POLICY
  #file("policys3secret.json")
  # policy      = "${file("policys3secret.json")}"
}

resource "aws_iam_policy_attachment" "test_attach" {
  name       = "test_attachment"
  roles      = [aws_iam_role.ec2_s3_secretmanager_role.name]
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.ec2_s3_secretmanager_role.name
}
#####
# Security Groups
#####
resource "aws_security_group" "internet" {
  vpc_id      = aws_vpc.vpc_network_VPC.id
  name        = "${local.app_name2}_egress_sg"
  description = "security group to allow all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    project = "${local.app_name2}"
  }
}

resource "aws_security_group" "public" {

  vpc_id      = aws_vpc.vpc_network_VPC.id
  name        = "${local.app_name2}_lb"
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
    project = "${local.app_name2}"
  }
}

// Create Security group to allow ingress traffic to nodejs app 
resource "aws_security_group" "private" {

  vpc_id      = aws_vpc.vpc_network_VPC.id
  name        = "${local.app_name2}_ingress_nodejs"
  description = "security group to allow inbound traffic on port 3000 from elb"
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.vpc_network_SubnetAPublic.cidr_block, aws_subnet.vpc_network_SubnetBPublic.cidr_block, aws_subnet.vpc_network_SubnetCPublic.cidr_block]
  }
  tags = {
    project = "${local.app_name2}"
  }
}

// Create Security group to allow ingress traffic to nodejs app 
resource "aws_security_group" "postgresdb" {
  vpc_id      = aws_vpc.vpc_network_VPC.id
  name        = "${local.app_name2}_ingress_postgresdb"
  description = "security group that allows ssh and all egress traffic"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.vpc_network_SubnetAPrivate.cidr_block, aws_subnet.vpc_network_SubnetBPrivate.cidr_block, aws_subnet.vpc_network_SubnetCPrivate.cidr_block]
  }
  tags = {
    project = "${local.app_name2}"
  }
}
#####
# ELB
#####
resource "aws_elb" "clb" {
  name = "elb-techtest5"


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
    project = "${local.app_name2}"
  }
}

#####
# DB
#####
resource "random_string" "dbpass" {
  length  = 8
  special = false
}

resource "aws_db_subnet_group" "testapp_db_group" {
  name       = "${local.app_name2}_db_group"
  subnet_ids = data.aws_subnet_ids.privatesubnets.ids

  tags = {
    Name    = "${local.app_name2}_db_group"
    Project = "${local.app_name2}"
  }
}
resource "aws_db_instance" "testapp_db" {
  identifier                          = "${local.app_name2}db"
  engine                              = "postgres"
  engine_version                      = "9.6.9"
  instance_class                      = var.db_instance_type
  allocated_storage                   = 10
  max_allocated_storage               = 20
  storage_type                        = "gp2"
  name                                = "app"
  username                            = "postgres"
  password                            = random_string.dbpass.result
  iam_database_authentication_enabled = true
  multi_az                            = true
  port                                = "5432"
  vpc_security_group_ids              = [aws_security_group.postgresdb.id]
  maintenance_window                  = "Mon:00:00-Mon:03:00"
  backup_window                       = "03:00-06:00"
  backup_retention_period             = 0
  db_subnet_group_name                = aws_db_subnet_group.testapp_db_group.id
  deletion_protection                 = false
  tags = {
    project = "${local.app_name2}"
  }
}
#####
# Secret Manager
#####
// Create a new secret with the password passed in as variable, this is set as the DB password 
resource "aws_secretsmanager_secret" "TestAppSecret2" {
  name        = "dev2/${local.app_name2}database1"
  description = "postgres credentials"
  # rotation_rules {
  #   automatically_after_days = 7
  # }
}

resource "aws_secretsmanager_secret_version" "TestAppCredentials2" {
  secret_id     = aws_secretsmanager_secret.TestAppSecret2.id
  secret_string = "{\"username\":\"postgres\",\"password\":\"${random_string.dbpass.result}\"}"
}


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
resource "aws_launch_configuration" "testapp_lc" {
  name_prefix     = "${local.app_name2}-launch-configuration-"
  image_id        = data.aws_ami.latest_ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.private.id, aws_security_group.internet.id]
  // Use the file content if that is 
  # user_data       = file("userdata.sh")
  user_data            = <<-EOT
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
    x=$(aws rds describe-db-instances --db-instance-identifier testappdb | jq '.DBInstances[0].Endpoint.Address')
    sed -i "s/\"localhost\"/$x/g" conf.toml
    sed -i '/DbPassword/c\\"DbPassword\" = \"${local.json_data}\"' conf.toml
    ./TechTestApp updatedb -s
    ./TechTestApp serve
  EOT
  #key_name             = "postgrestest"
  iam_instance_profile = aws_iam_instance_profile.test_profile.name

  ebs_block_device {
    device_name           = "/dev/xvdz"
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = true
  }


  root_block_device {
    volume_size = "50"
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_db_instance.testapp_db]
}
######
# Autoscaling group
######
resource "aws_autoscaling_group" "testapp_asg" {
  name                      = "${local.app_name2}_asg"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.testapp_lc.name
  vpc_zone_identifier       = data.aws_subnet_ids.privatesubnets.ids
  load_balancers            = [aws_elb.clb.id]

  tags = [
    {
      key                 = "Project"
      value               = "${local.app_name2}"
      propagate_at_launch = true
    },
    {
      key                 = "asg"
      value               = "yes"
      propagate_at_launch = true
      Name                = "${local.app_name2}_asg"
    },
  ]

  timeouts {
    delete = "30m"
  }
}



