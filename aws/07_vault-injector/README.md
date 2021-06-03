# Vault Injector

## Install

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault --set "injector.externalVaultAddr=https://vault.example.com"
```

## Configuration

```bash
export VAULT_ADDR="https://vault.example.com"
vault login -method=aws header_value=https://vault.example.com
vault auth enable kubernetes
```

### Kubernetes Key and Token

Vault secret:

```bash
VAULT_HELM_SECRET_NAME=$(kubectl get secrets --output=json | jq -r '.items[].metadata | select(.name|startswith("vault-token-")).name')
kubectl describe secret $VAULT_HELM_SECRET_NAME
```

Kubernetes:

```bash
TOKEN_REVIEW_JWT=$(kubectl get secret $VAULT_HELM_SECRET_NAME --output='go-template={{ .data.token }}' | base64 --decode)
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')
```

Save in Vault:

```bash
vault write auth/kubernetes/config \
  token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
  kubernetes_host="$KUBE_HOST" \
  kubernetes_ca_cert="$KUBE_CA_CERT"
```

```bash
Success! Data written to: auth/kubernetes/config
```
