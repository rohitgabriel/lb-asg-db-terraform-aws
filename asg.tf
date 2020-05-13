# // Create Launch Configuration and Auto Scaling group 
# ##############################################################
# # Data sources to get VPC, subnets and security group details
# ##############################################################


# data "aws_subnet_ids" "all" {
#   vpc_id     = module.vpc.vpc_id
#   depends_on = [module.vpc]
# }

# data "aws_subnet_ids" "selected" {
#   vpc_id     = module.vpc.vpc_id
#   depends_on = [module.vpc]
#   filter {
#     name   = "tag:Name"
#     values = ["*private*"]
#   }
# }

# data "aws_security_group" "default" {
#   vpc_id     = module.vpc.vpc_id
#   name       = "sg_demo"
#   depends_on = [module.vpc]
# }

# data "aws_ami" "latest_ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"] # Canonical

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }
# locals {
#   json_data = jsondecode(data.aws_secretsmanager_secret_version.by-version-stage.secret_string)["password"]
# }
# ######
# # Launch configuration
# ######
# resource "aws_launch_configuration" "this" {
#   name_prefix = "testapp-launch-configuration-"
#   image_id    = data.aws_ami.latest_ubuntu.id
#   #image_id       = "ami-02a599eb01e3b3c5b"
#   instance_type   = "t2.micro"
#   security_groups = [data.aws_security_group.default.id]
#   // Use the file content if that is 
#   # user_data       = file("userdata.sh")
#   user_data = <<-EOT
#     #!/bin/bash
#     apt-get update -y
#     snap install --classic go
#     apt-get install jq -y
#     cp /snap/bin/go /usr/local/bin/
#     apt-get install go-dep -y
#     cd /tmp
#     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#     apt install unzip -y
#     unzip awscliv2.zip
#     ./aws/install
#     aws s3 cp s3://eittestappbucket1/dist ~/application --recursive
#     cd ~/application
#     chmod 755 ./TechTestApp
#     sed -i '/ListenHost/c\"ListenHost" = "0.0.0.0"' conf.toml
#     aws rds describe-db-instances --db-instance-identifier testapp-postgres > /tmp/dbdetails.txt
#     x=$(aws rds describe-db-instances --db-instance-identifier testapp-postgres| jq '.DBInstances[0].Endpoint.Address')
#     sed -i "s/\"localhost\"/$x/g" conf.toml
#     sed -i '/DbPassword/c\\"DbPassword\" = \"${local.json_data}\"' conf.toml
#     ./TechTestApp updatedb -s
#     ./TechTestApp serve
#   EOT
#   #key_name        = var.key_name
#   #iam_instance_profile = "postgres-secret-read"
#   iam_instance_profile = aws_iam_instance_profile.test_profile.name

#   lifecycle {
#     create_before_destroy = true
#   }
#   depends_on = [module.db]
# }
# ######
# # Autoscaling group
# ######
# module "demo_asg" {
#   source = "terraform-aws-modules/autoscaling/aws"

#   name                 = "testapp-asg-instance"
#   launch_configuration = aws_launch_configuration.this.name # Use the existing launch configuration
#   create_lc            = false                              # disables creation of launch configuration
#   #lc_name = "demo-lc"

#   image_id = "ami-02a599eb01e3b3c5b"
#   #image_id        = data.aws_ami.amazon_linux.id
#   #image_id        = var.AMI_ID
#   instance_type                = "t2.micro"
#   security_groups              = [data.aws_security_group.default.id]
#   load_balancers               = [module.elb.this_elb_id]
#   associate_public_ip_address  = true
#   key_name                     = "postgrestest"
#   recreate_asg_when_lc_changes = true

#   ebs_block_device = [
#     {
#       device_name           = "/dev/xvdz"
#       volume_type           = "gp2"
#       volume_size           = "50"
#       delete_on_termination = true
#     },
#   ]

#   root_block_device = [
#     {
#       volume_size = "50"
#       volume_type = "gp2"
#     },
#   ]

#   # Auto scaling group
#   asg_name                  = "demo-asg"
#   vpc_zone_identifier       = module.vpc.public_subnets
#   health_check_type         = "EC2"
#   min_size                  = 1
#   max_size                  = 3
#   desired_capacity          = 2
#   wait_for_capacity_timeout = 0

#   tags = [
#     {
#       key                 = "Project"
#       value               = "testapp"
#       propagate_at_launch = true
#     },
#     {
#       key                 = "Project"
#       value               = "testapp"
#       propagate_at_launch = true
#     },
#   ]
# }
