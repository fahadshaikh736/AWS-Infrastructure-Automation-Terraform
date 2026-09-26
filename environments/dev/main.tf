terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source = "../../modules/vpc"

  project_name = "aws-infra-automation"
}
###########################
# Security Group for ALB
###########################
resource "aws_security_group" "alb" {
  name_prefix = "aws-infra-automation-alb-"
  vpc_id      = module.vpc.vpc_id
  description = "Allow inbound HTTP/HTTPS to the ALB"

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-infra-automation-alb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

###########################
# ALB Module
###########################
module "alb" {
  source = "../../modules/alb"

  project_name      = "aws-infra-automation"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = aws_security_group.alb.id
  container_port    = 8080
  health_check_path = "/health"
}

