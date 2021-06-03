# Vault

- HashiCorp: [Vault](https://www.vaultproject.io/)
  - [Learn](https://learn.hashicorp.com/vault)
    - [Install](https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started)
  - [Documentation](https://www.vaultproject.io/docs)

## Prerequisites

- Helm 3.0+
- Kubernetes 1.9+

## AWS EKS + Vault

[Quick Start](aws/README.md)

1. Packer: AMI
1. Resources: Subnets, Route, Load Balancer, Target Group, Route 53
1. Terraform: EC2
1. Vault: Start a server
1. Kubernetes: Deploy Service with externalName
1. Vault Authentication: with AWS IAM
1. Vault + Kubernetes: Vault Injector
1. Example: Inject Vault Token

### Architecture

![](./aws/images/resources.png)
