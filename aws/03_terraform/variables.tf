variable "profile" {
  default     = "default"
  description = "$HOME/.aws/credentials: [default]"
}

variable "region" {
  default     = "ap-northeast-2"
  description = "Seoul"
}

variable "vpc_id" {
  default     = "vpc-xxxxxxxxxxxxxxxxx"
  description = "VPC"
}

variable "subnet_id" {
  default     = "subnet-xxxxxxxxxxxxxxxxx"
  description = "Private Vault Subnet A"
}

variable "security_group" {
  default     = ["sg-xxxxxxxxxxxxxxxxx"]
  description = "Vault Security Group ID"
}

variable "lb_arn" {
  default     = "arn:aws:elasticloadbalancing:ap-northeast-2:xxxxxxxxxxxx:loadbalancer/net/Vault/xxxxxxxxxxxxxxxx"
  description = "Vault ELB"
}

variable "lb_tg_arn" {
  default     = "arn:aws:elasticloadbalancing:ap-northeast-2:xxxxxxxxxxxx:targetgroup/Vault/xxxxxxxxxxxxxxxx"
  description = "Vault Target Group"
}

variable "key_name" {
  default     = "vault"
  description = "EC2 Key Pair Name"
}

variable "private_key" {
  default     = "~/.ssh/vault.pem"
  description = "EC2 Private Key"
}

variable "iam_instance_profile" {
  default     = "vault-ec2"
  description = "IAM Role for Vault: IAM, KMS"
}

variable "kms_key_id" {
  default     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  description = "Vault KMS Key ID"
}

variable "vault_port" {
  default     = 8200
  description = "Vault Port"
}

variable "instance_count" {
  default     = 1
  type        = number
  description = "Number of instances"
}

variable "ami_id" {
  default     = "ami-xxxxxxxxxxxxxxxxx"
  description = "Vault AMI"
}

variable "instance_type" {
  default     = "t3a.medium"
  description = "EC2 Instance Type: 2cpu, 4GiB"
}

variable "volume_size" {
  default     = 30
  type        = number
  description = "EBS Volume Size"
}

variable "volume_type" {
  default     = "gp2"
  description = "EBS Volume Type: General Purpose SSD"
}

variable "user" {
  default     = "ubuntu"
  description = "Ubuntu"
}

# Time (sec) to wait for cloud instances to come
# up before running the ece installer (ansible)
variable "sleep_timeout" {
  default = "60"
  type    = string
}

# Bastion
variable "bastion_security_group" {
  default     = "sg-xxxxxxxxxxxxxxxxx"
  description = "Bastion Security Group ID"
}

# Bastion for Ansible playbook
variable "bastion_eip" {
  default     = "eipalloc-xxxxxxxxxxxxxxxxx"
  description = "Elastic IP Allocation ID"
}

variable "bastion_user" {
  default     = "ec2-user"
  description = "Amazon Linux 2 AMI"
}

variable "bastion_private_key" {
  default     = "~/.ssh/bastion.pem"
  description = "Bastion Private Key"
}
