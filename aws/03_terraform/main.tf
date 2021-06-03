terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

# Data sources to get VPC, subnet, ELB, EIP, ELB Target Group, security group and AMI details
data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_eip" "bastion" {
  id = var.bastion_eip
}

data "aws_lb" "lb" {
  arn = var.lb_arn
}

data "aws_lb_target_group" "lb_tg" {
  arn = var.lb_tg_arn
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = "vault"
  instance_count = var.instance_count

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile
  monitoring             = true
  vpc_security_group_ids = var.security_group
  subnet_ids             = [var.subnet_id]

  root_block_device = [
    {
      volume_type           = var.volume_type
      volume_size           = var.volume_size
      delete_on_termination = true
      encrypted             = false
    },
  ]

  tags = {
    Name       = "vault"
    Terraform  = "true"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_id        = module.ec2.id[0]
  target_group_arn = data.aws_lb_target_group.lb_tg.arn
  port             = var.vault_port
}

