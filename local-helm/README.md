# Local Helm

- doc: [helm chart](https://www.vaultproject.io/docs/platform/k8s/helm)
- learn: [Install the Vault Helm chart](https://learn.hashicorp.com/tutorials/vault/kubernetes-minikube?in=vault/kubernetes#install-the-vault-helm-chart)
- chart
  - [consul](https://artifacthub.io/packages/helm/hashicorp/consul)
  - [vault](https://artifacthub.io/packages/helm/hashicorp/vault)

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
```

## Install consul

[helm-consul-values.yml](helm-consul-values.yml)

```bash
cd local-helm
helm install consul hashicorp/consul --values helm-consul-values.yml
```

status:

```bash
helm status consul

NAME: consul
LAST DEPLOYED: Thu Jan 21 14:28:01 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
```

pods:

```bash
kubectl get pods

NAME                     READY   STATUS    RESTARTS   AGE
consul-consul-f59rz      1/1     Running   0          82s
consul-consul-server-0   1/1     Running   0          82s
```

## Install vault

[helm-vault-values.yml](helm-vault-values.yml)

```bash
helm install vault hashicorp/vault --values helm-vault-values.yml
```

```bash
helm status vault

NAME: vault
LAST DEPLOYED: Thu Jan 21 14:29:54 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

`vault-x` is executes a status check defined in a readinessProbe: 

```bash
kubectl get pods

NAME                                  READY   STATUS    RESTARTS   AGE
consul-consul-f59rz                   1/1     Running   0          2m10s
consul-consul-server-0                1/1     Running   0          2m10s
vault-0                               0/1     Running   0          8s
vault-1                               0/1     Running   0          7s
vault-2                               0/1     Running   0          6s
vault-agent-injector-c54c5747-84vz6   1/1     Running   0          8s
```

pod status:

```bash
kubectl exec vault-0 -- vault status

Key                Value
---                -----
Seal Type          shamir
Initialized        false
Sealed             true
Total Shares       0
Threshold          0
Unseal Progress    0/0
Unseal Nonce       n/a
Version            1.6.1
Storage Type       consul
HA Enabled         true
command terminated with exit code 2
```

port forward:

```bash
kubectl port-forward vault-0 8200:8200
```

Go: [http://localhost:8200/ui](http://localhost:8200/ui)

## Initialize and unseal vault

Initialize Vault with **one key share** and **one key threshold**:

```bash
kubectl exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
```

Get unseal key `unseal_keys_b64` in `cluster-keys.json`:

```bash
VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
```

unseal vault on `vault-0` ~ `vault-2`:

```bash
kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec vault-2 -- vault operator unseal $VAULT_UNSEAL_KEY
```

Verify all the Vault pods are running and ready:

```bash
kubectl get pods

NAME                                  READY   STATUS    RESTARTS   AGE
consul-consul-f59rz                   1/1     Running   0          9m50s
consul-consul-server-0                1/1     Running   0          9m50s
vault-0                               1/1     Running   0          7m48s
vault-1                               1/1     Running   0          7m47s
vault-2                               1/1     Running   0          7m46s
vault-agent-injector-c54c5747-84vz6   1/1     Running   0          7m48s
```

## Set a secret in vault

root token:

```bash
cat cluster-keys.json | jq -r ".root_token"
```

start shell on `vault-0`:

```bash
kubectl exec -it vault-0 -- /bin/sh
```

login wiht the root token:

```bash
/ $ vault login

Token (will be hidden): 
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.QNk2xkdkT2oc1adm1BOheR62
token_accessor       NO7TFkM5AyrgbcQXFiOMCiF7
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

enable kv-v2 secrets:

```bash
vault secrets enable -path=secret kv-v2
```

create a secret:

```bash
vault kv put secret/webapp/config username="static-user" password="static-password"
vault kv get secret/webapp/config

====== Data ======
Key         Value
---         -----
password    static-password
username    static-user
```

## Configure Kubernetes authentication

Enable kubernetes auth method:

```bash
vault auth enable kubernetes

Success! Enabled kubernetes auth method at: kubernetes/
```

Configure the Kubernetes authentication method to use the service account token, the location of the Kubernetes host, and its certificate.

```bash
vault write auth/kubernetes/config \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

policy:

```bash
vault policy write webapp - <<EOF
path "secret/data/webapp/config" {
  capabilities = ["read"]
}
EOF
```

Create a Kubernetes authentication role:

```bash
vault write auth/kubernetes/role/webapp \
  bound_service_account_names=vault \
  bound_service_account_namespaces=default \
  policies=webapp \
  ttl=24h
```

```bash
exit
```

## Launch a web application

[deployment-01-webapp.yml](deployment-01-webapp.yml)

```bash
kubectl apply --filename deployment-01-webapp.yml
```

port forward:

```bash
kubectl port-forward \
    $(kubectl get pod -l app=webapp -o jsonpath="{.items[0].metadata.name}") \
    8080:8080
```

```bash
curl http://localhost:8080

{"password"=>"static-password", "username"=>"static-user"}
```

```bash
kubectl delete -f deployment-01-webapp.yml
helm uninstall vault
helm uninstall consul
```
