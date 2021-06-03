# AWS + Vault

## Get Token

```bash
export VAULT_ADDR="https://vault.example.com"
# export AWS_PROFILE=<AWS-Profile>
vault login -method=aws header_value=vault.example.com # role=admin
```

## Install

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [AWS CLI](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/install-cliv2-mac.html)
- [Vault](https://www.vaultproject.io/downloads)
- [Packer](https://www.packer.io/downloads)
- [Terraform](https://www.terraform.io/downloads.html)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Contents

1. [Packer](01_packer/README.md): AMI
1. [Resources](02_resources/README.md): Subnets, Route, Load Balancer, Target Group, Route 53
1. [Terraform](03_terraform/README.md): EC2
1. [Vault](04_vault/README.md): Start a server
1. [Kubernetes](05_kubernetes/vault.yaml): Deploy Service with externalName
1. [Vault Authentication](06_admin/README.md): with AWS IAM
1. [Vault + Kubernetes](07_vault-injector/README.md): Vault Injector
1. [Example](08_example/README.md): Inject Vault Token
