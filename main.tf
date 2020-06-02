provider "aws" {
  version = ">= 2.53"
  region  = var.AWS_REGION
}

terraform {
  required_version = ">= 0.12"

  backend "remote" {
    organization = "testapp"

    workspaces {
      name = "dev"
    }
  }
}

module "vpc" {
  source = "./vpc"

  app_name = var.app_name
}

module "db" {
  source = "./db"

  vpc_security_group_ids = [module.vpc.db_security_group_id]
  subnet_ids             = module.vpc.private_subnets
  app_name               = var.app_name
}

#####
# IAM
#####
// Create new IAM Role with s3, secretsmanager and RDS access
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_s3_secretmanager_role" {
  name               = "s3-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# data "aws_iam_policy_document" "policy" {
# statement {
#   sid = "1"
#   actions = [
#     "secretsmanager:GetResourcePolicy",
#     "secretsmanager:GetSecretValue",
#     "secretsmanager:DescribeSecret",
#     "secretsmanager:ListSecretVersionIds"
#   ]
#   resources = [
#     "${aws_secretsmanager_secret.TestAppSecret3.arn}",
#   ]
# }

# statement {
#   sid = "2"
#   actions = [
#     "secretsmanager:GetRandomPassword",
#     "secretsmanager:ListSecrets"
#   ]
#   resources = [
#     aws_secretsmanager_secret_version.TestAppCredentials3.arn
#   ]
# }

# statement {
#   sid = "3"
#   actions = [
#     "rds:*"
#   ]
#   resources = [
#     module.db.arn
#   ]
# }

# statement {
#   sid = "4"
#   actions = [
#     "s3:GetAccessPoint",
#     "s3:GetLifecycleConfiguration",
#     "s3:GetBucketTagging",
#     "s3:GetInventoryConfiguration",
#     "s3:GetObjectVersionTagging",
#     "s3:ListBucketVersions",
#     "s3:GetBucketLogging",
#     "s3:ListBucket",
#     "s3:GetAccelerateConfiguration",
#     "s3:GetBucketPolicy",
#     "s3:GetObjectVersionTorrent",
#     "s3:GetObjectAcl",
#     "s3:GetEncryptionConfiguration",
#     "s3:GetBucketObjectLockConfiguration",
#     "s3:GetBucketRequestPayment",
#     "s3:GetAccessPointPolicyStatus",
#     "s3:GetObjectVersionAcl",
#     "s3:GetObjectTagging",
#     "s3:GetMetricsConfiguration",
#     "s3:HeadBucket",
#     "s3:GetBucketPublicAccessBlock",
#     "s3:GetBucketPolicyStatus",
#     "s3:ListBucketMultipartUploads",
#     "s3:GetObjectRetention",
#     "s3:GetBucketWebsite",
#     "s3:ListAccessPoints",
#     "s3:ListJobs",
#     "s3:GetBucketVersioning",
#     "s3:GetBucketAcl",
#     "s3:GetObjectLegalHold",
#     "s3:GetBucketNotification",
#     "s3:GetReplicationConfiguration",
#     "s3:ListMultipartUploadParts",
#     "s3:GetObject",
#     "s3:GetObjectTorrent",
#     "s3:GetAccountPublicAccessBlock",
#     "s3:ListAllMyBuckets",
#     "s3:DescribeJob",
#     "s3:GetBucketCORS",
#     "s3:GetAnalyticsConfiguration",
#     "s3:GetObjectVersionForReplication",
#     "s3:GetBucketLocation",
#     "s3:GetAccessPointPolicy",
#     "s3:GetObjectVersion"
#   ]
#   resources = [
#     "*"
#   ]
#   }
# }

# resource "aws_iam_policy" "policy" {
#   name        = "${var.app_name}_policy"
#   description = "${var.app_name} policy"
#   # policy      = data.aws_iam_policy_document.policy.json
# }

# resource "aws_iam_policy_attachment" "test_attach" {
#   name       = "test_attachment"
#   roles      = [aws_iam_role.ec2_s3_secretmanager_role.name]
#   policy_arn = aws_iam_policy.policy.arn
# }

# resource "aws_iam_instance_profile" "test_profile" {
#   name = "test_profile"
#   role = aws_iam_role.ec2_s3_secretmanager_role.name
# }

#####
# ELB
#####
resource "aws_elb" "clb" {
  name                        = "elb-techtest5"
  subnets                     = module.vpc.public_subnets
  security_groups             = [module.vpc.lb_security_group_id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  listener {
    instance_port     = var.app_port
    instance_protocol = "http"
    lb_port           = var.lb_port
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:${var.app_port}/"
    interval            = 30
  }

  tags = {
    project = "${var.app_name}"
  }
}

#####
# Secret Manager
#####
// Create a new secret with the password passed in as variable, this is set as the DB password 
# resource "aws_secretsmanager_secret" "TestAppSecret3" {
#   name        = "dev3/${var.app_name}database3"
#   description = "postgres credentials"
# }

# resource "aws_secretsmanager_secret_version" "TestAppCredentials3" {
#   secret_id = aws_secretsmanager_secret.TestAppSecret3.id
#   secret_string = "{\"username\":\"postgres\",\"password\":\"${module.db.db_password}\"}"
# }

# locals {
#   json_data = jsondecode(aws_secretsmanager_secret_version.TestAppCredentials3.secret_string)["password"]
# }

######
# Launch configuration
######
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

resource "aws_launch_configuration" "testapp_lc" {
  name_prefix     = "${var.app_name}-launch-configuration-"
  image_id        = data.aws_ami.latest_ubuntu.id
  instance_type   = var.instance_type
  security_groups = [module.vpc.appserver_security_group_id]
  # iam_instance_profile = aws_iam_instance_profile.test_profile.name
  user_data = <<-EOT
    #cloud-config
    packages:
      - jq
      - unzip
      - golang-go
    write_files:
      - path: /opt/TechTestApp/conf.toml
        content: |
          "DbUser" = "postgres"
          "DbPassword" = "${module.db.db_password}"
          "DbName" = "${module.db.db_instance_name}"
          "DbPort" = "5432"
          "DbHost" = "${module.db.db_instance_address}"
          "ListenHost" = "0.0.0.0"
          "ListenPort" = "3000"
    runcmd:
      - mkdir -p /opt/TechTestApp
      - curl -L -o /tmp/TechTestApp.zip https://github.com/servian/TechTestApp/releases/download/v.0.6.0/TechTestApp_v.0.6.0_linux64.zip
      - unzip /tmp/TechTestApp.zip  -d /opt/TechTestApp
      - mv /opt/TechTestApp/dist/assets /opt/TechTestApp/assets
      - mv /opt/TechTestApp/dist/TechTestApp /opt/TechTestApp/
      - rm -rf /opt/TechTestApp/dist/
      - `/opt/TechTestApp/TechTestApp updatedb -s`
      - `/opt/TechTestApp/TechTestApp serve &`
  EOT

  # user_data = <<-EOT
  #   #!/bin/bash
  #   apt-get update -y
  #   snap install --classic go
  #   apt-get install jq -y
  #   cp /snap/bin/go /usr/local/bin/
  #   apt-get install go-dep -y
  #   cd /tmp
  #   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  #   apt install unzip -y
  #   unzip awscliv2.zip
  #   ./aws/install
  #   aws s3 cp s3://eittestappbucket1/dist ~/application --recursive
  #   cd ~/application
  #   chmod 755 ./TechTestApp
  #   sed -i '/ListenHost/c\"ListenHost" = "0.0.0.0"' conf.toml
  #   aws rds describe-db-instances --db-instance-identifier testapp-postgres > /tmp/dbdetails.txt
  #   x=$(aws rds describe-db-instances --db-instance-identifier testappdb | jq '.DBInstances[0].Endpoint.Address')
  #   sed -i "s/\"localhost\"/$x/g" conf.toml
  #   sed -i '/DbPassword/c\\"DbPassword\" = \"${module.db.db_password}\"' conf.toml
  #   ./TechTestApp updatedb -s
  #   ./TechTestApp serve
  # EOT
  key_name = "postgrestest"

  ebs_block_device {
    device_name           = var.ebs_device_name
    volume_type           = var.ebs_volume_type
    volume_size           = var.ebs_volume_size
    delete_on_termination = true
  }

  root_block_device {
    volume_size = "50"
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [module.db]
}

######
# Autoscaling group
######
resource "aws_autoscaling_group" "testapp_asg" {
  name                      = "${var.app_name}_asg"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 1200
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.testapp_lc.name
  vpc_zone_identifier       = module.vpc.private_subnets
  load_balancers            = [aws_elb.clb.id]

  tags = [
    {
      key                 = "Project"
      value               = "${var.app_name}"
      propagate_at_launch = true
    },
    {
      key                 = "asg"
      value               = "yes"
      propagate_at_launch = true
      Name                = "${var.app_name}_asg"
    },
  ]

  timeouts {
    delete = "30m"
  }
}
