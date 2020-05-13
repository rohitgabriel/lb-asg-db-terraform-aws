# resource "aws_security_group" "node" {
#   vpc_id      = module.vpc.vpc_id
#   name        = "sg_demo"
#   description = "security group that allows ssh and all egress traffic"
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["111.69.94.233/32"]
#   }

#   ingress {
#     from_port   = 3000
#     to_port     = 3000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port = 5432
#     to_port   = 5432
#     protocol  = "tcp"
#     #cidr_blocks = ["0.0.0.0/0"]
#     cidr_blocks = module.vpc.public_subnets_cidr_blocks
#   }
#   ingress {
#     from_port = 3000
#     to_port   = 3000
#     protocol  = "tcp"
#     #cidr_blocks = ["0.0.0.0/0"]
#     cidr_blocks = module.vpc.public_subnets_cidr_blocks
#   }

#   tags = {
#     access = "homeip"
#   }
# }

