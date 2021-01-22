# Vault

- HashiCorp: [Vault](https://www.vaultproject.io/)
  - [Learn](https://learn.hashicorp.com/vault)
    1. [Install](https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started)
  - [Documentation](https://www.vaultproject.io/docs)

## Prerequisites

- Helm 3.0+
- Kubernetes 1.9+

## Contents

- [x] [Install](install/README.md)
- [ ] Kubernetes
  - [x] [Local Helm](local-helm/README.md)
  - [x] [Injecting Secrets](local-helm-sidecar/README.md) via Local Helm Sidecar
  - [x] [Kubernets + External Vault](external-vault/README.md)
  - [ ] [as a Cert Manager](cert-manager/README.md)
- [ ] HA
- [ ] TLS
- [ ] PGP
- [ ] Access
  - [ ] Authentication Methods
    - [ ] GitHub
  - [ ] Entities
  - [ ] Groups
  - [ ] Leases
- [ ] ACL Policy
- [ ] Storage
- [ ] Secrets Engine
