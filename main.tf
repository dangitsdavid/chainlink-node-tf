# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
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

  enable_vpn_gateway = false
  
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

# asg - wip
resource "aws_autoscaling_group" "cl-node-asg" {
  name                 = "cl-terra-asg"
  max-size             = 2
  min_size             = 2
  desired_capacity     = 2
  launch_configuration = 
  default_cooldown     = 300
  vpc_zone_identifier  = 
}

# aws ec2 instance
resource "aws_instance" "terraform-test" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t3.micro"
  
  tags = {
    Name = "HelloTerraform"
  }
}

# resource "<provider>_<resource_type>" "name" {
#     config options ...
#     key = "value"
#     key2 = "another value"
# }