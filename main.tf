# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.55.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "/Users/daviddang/.aws/creds"
}

# module creates VPC resource in AWS
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "cl-terra-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  # one NAT gateway per subnet (default behavior)
  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = false

  #enable_vpn_gateway = false
  
  # public access to RDS instance / not recommended for Prod
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# ubuntu image
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# amazon linux 2 image
data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

# chainlink node asg - wip
resource "aws_autoscaling_group" "node" {
  name                 = "node-asg"
  max_size             = var.node_max_size
  min_size             = var.node_min_size
  desired_capacity     = var.node_desired_capacity
  launch_configuration = aws_launch_configuration.node.id
  default_cooldown     = 300
  vpc_zone_identifier  = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  tag {
    key                 = "Name"
    value               = "ChainlinkTfNode"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "node" {
  name = "node-launch-config"
  image_id = data.aws_ami.amazon-linux-2.id
  instance_type = var.node_instance_type
  key_name = "quickstart-staging"
  enable_monitoring = false
  security_groups = [aws_security_group.node.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = var.node_volume_size
  }
}

resource "aws_security_group" "node" {
  name        = "node_sg"
  description = "Security group for Chainlink node"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    {
      description      = "SSH from Bastion"
      from_port        = "22"
      to_port          = "22"
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/16"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "Chainlink node Web GUI"
      from_port        = "6688"
      to_port          = "6688"
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/16"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
}

# bastion host asg - wip
resource "aws_autoscaling_group" "bastion" {
  name                 = "bastion-asg"
  max_size             = var.bastion_max_size
  min_size             = var.bastion_min_size
  desired_capacity     = var.bastion_desired_capacity
  launch_configuration = aws_launch_configuration.bastion.id
  default_cooldown     = 300
  vpc_zone_identifier  = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  tag {
    key                 = "Name"
    value               = "BastionHostTf"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "bastion" {
  name = "bastion-launch-config"
  image_id = data.aws_ami.amazon-linux-2.id
  instance_type = var.bastion_instance_type
  key_name = "quickstart-staging"
  enable_monitoring = false
  associate_public_ip_address = true
  security_groups = [aws_security_group.bastion.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = var.bastion_volume_size
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion_sg"
  description = "Security group for bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    {
      description      = "SSH access"
      from_port        = "22"
      to_port          = "22"
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
}

## Sample resource template
# resource "<provider>_<resource_type>" "name" {
#     config options ...
#     key = "value"
#     key2 = "another value"
# }