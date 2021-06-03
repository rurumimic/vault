packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "profile" {
  type        = string
  default     = "default"
  description = "$HOME/.aws/credentials: [default]"
}

variable "ami_name" {
  type        = string
  default     = "vault"
  description = "Name of this AMI"
}

variable "instance_type" {
  type        = string
  default     = "t3a.medium"
  description = "EC2 Instance Type: 2cpu, 4GiB"
}

variable "region" {
  type        = string
  default     = "ap-northeast-2"
  description = "Seoul"
}

variable "vpc_id" {
  type        = string
  default     = "vpc-xxxxxxxxxxxxxxxxx"
  description = "My VPC"
}

variable "subnet_id" {
  type        = string
  default     = "subnet-xxxxxxxxxxxxxxxxx"
  description = "Public Bastion Subnet A"
}

variable "ansible_playbook" {
  type        = string
  default     = "./ansible/playbook.yml"
  description = "Ansible Playbook YAML file"
}

source "amazon-ebs" "ubuntu" {
  profile                     = var.profile
  ami_name                    = var.ami_name
  instance_type               = var.instance_type
  region                      = var.region
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "ansible" {
    playbook_file = var.ansible_playbook
  }
}
