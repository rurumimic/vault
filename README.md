# Vault

- HashiCorp: [Vault](https://www.vaultproject.io/)
  - [Learn](https://learn.hashicorp.com/vault)
    - [Install](https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started)
  - [Documentation](https://www.vaultproject.io/docs)

## Prerequisites

- Helm 3.0+
- Kubernetes 1.9+

## Documentations

- [Install & Start](docs/start.vault.md)
- Easy Tutorial: [Key Value Secrets](docs/kv.secrets.md)
- Install in [Local with Helm](local-helm/README.md): share kubernetes's token with pod
- Inject secrets via [sidecar](inject-secrets-via-sidecar/README.md): practice gradually
- External Vault: same as [Vault + Kubernetes](aws/07_vault-injector/README.md), [Cronjob Example](aws/08_example/README.md)
- Generate [PKI](docs/pki.md): with cert-manager
- [Password Rotation](docs/password.md): Rotate Linux User's Password
- [SSH OTP](docs/ssh.otp.md): One Time Password with SSH
- [AWS STS](docs/aws.iam.sts.md): AssumeRole, Federation Token

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
