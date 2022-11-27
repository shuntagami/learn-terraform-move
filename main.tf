provider "aws" {
  region = var.region

  default_tags {
    tags = {
      hashicorp-learn = "move-config"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway      = var.vpc_enable_nat_gateway
  map_public_ip_on_launch = true

  tags = var.vpc_tags
}

module "web_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  vpc_id = module.vpc.vpc_id

  use_name_prefix = false

  name        = "terraform-learn-move-sg"
  description = "Security Group managed by Terraform"

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "ec2_instance" {
  source         = "./modules/compute"
  security_group = module.web_security_group.security_group_id
  public_subnets = module.vpc.public_subnets
}

moved {
  from = module.security_group.aws_security_group.sg_8080
  to   = module.web_security_group.aws_security_group.this[0]
}

moved {
  from = module.security_group.aws_security_group_rule.ingress_rule
  to   = module.web_security_group.aws_security_group_rule.ingress_with_cidr_blocks[0]
}

moved {
  from = module.security_group.aws_security_group_rule.egress_rule
  to   = module.web_security_group.aws_security_group_rule.egress_with_cidr_blocks[0]
}

moved {
  from = aws_instance.example
  to = module.ec2_instance.aws_instance.example
}
