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
