# Kubernetes + External Vault

```bash
vagrant up
vagrant ssh node1
vagrant ssh node2
```

## Install Vault in node1

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install -y vault
sudo snap install jq
```

### Run Vault

```bash
vault server -dev -dev-root-token-id root -dev-listen-address 0.0.0.0:8200
```

another terminal:

```bash
export VAULT_ADDR=http://0.0.0.0:8200
vault login root
vault kv put secret/devwebapp/config username='giraffe' password='salsa'
vault read -format json secret/data/devwebapp/config | jq ".data.data"
```

```json
{
  "password": "salsa",
  "username": "giraffe"
}
```

## Install Kubernetes + Helm in node2

```bash
sudo snap install microk8s --classic --channel=1.19
sudo snap install helm --classic
sudo snap install jq
sudo usermod -a -G microk8s vagrant
sudo chown -f -R vagrant /home/vagrant/.kube
echo "alias kubectl='microk8s kubectl'" >> /home/vagrant/.bash_aliases
echo 'source <(kubectl completion bash)' >> /home/vagrant/.bashrc
exit
```

```bash
microk8s enable dns storage
kubectl config view --raw > /home/vagrant/.kube/config
chmod 600 /home/vagrant/.kube/config
```

```bash
EXTERNAL_VAULT_ADDR=192.168.33.101
```

### Deploy application with hard-coded Vault address

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: internal-app
EOF
```

```bash
cat <<EOF | kubectl apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devwebapp
  labels:
    app: devwebapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: devwebapp
  template:
    metadata:
      labels:
        app: devwebapp
    spec:
      serviceAccountName: internal-app
      containers:
      - name: app
        image: burtlo/devwebapp-ruby:k8s
        imagePullPolicy: Always
        env:
        - name: VAULT_ADDR
          value: "http://$EXTERNAL_VAULT_ADDR:8200"
EOF
```

```bash
kubectl exec \
  $(kubectl get pod -l app=devwebapp -o jsonpath="{.items[0].metadata.name}") \
  -- curl -s localhost:8080 ; echo
```

```json
{"password"=>"salsa", "username"=>"giraffe"}
```

### Deploy service and endpoints to address an external Vault

```bash
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Service
metadata:
  name: external-vault
  namespace: default
spec:
  ports:
  - protocol: TCP
    port: 8200
---
apiVersion: v1
kind: Endpoints
metadata:
  name: external-vault
subsets:
  - addresses:
      - ip: $EXTERNAL_VAULT_ADDR
    ports:
      - port: 8200
EOF
```

```bash
kubectl exec \
  $(kubectl get pod -l app=devwebapp -o jsonpath="{.items[0].metadata.name}") \
  -- curl -s http://external-vault:8200/v1/sys/seal-status | jq
```

```json
{
  "type": "shamir",
  "initialized": true,
  "sealed": false,
  "t": 1,
  "n": 1,
  "progress": 0,
  "nonce": "",
  "version": "1.6.1",
  "migration": false,
  "cluster_name": "vault-cluster-b14bd93e",
  "cluster_id": "9dd27f2d-acc8-578d-8ea9-825d0064fd39",
  "recovery_seal": false,
  "storage_type": "inmem"
}
```

[deployment-01-external-vault-service.yml](deployment-01-external-vault-service.yml)

```bash
cd /vagrant/external-vault
kubectl apply -f deployment-01-external-vault-service.yml
```

```bash
kubectl exec \
  $(kubectl get pod -l app=devwebapp-through-service -o jsonpath="{.items[0].metadata.name}") \
  -- curl -s localhost:8080 ; echo

{"password"=>"salsa", "username"=>"giraffe"}
```

## Install the Vault Helm chart configured to address an external Vault

### Define a Kubernetes service account

```bash
cat <<EOF | kubectl create -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
---
apiVersion: v1
kind: Secret
metadata:
  name: vault-auth
  annotations:
    kubernetes.io/service-account.name: vault-auth
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
  - kind: ServiceAccount
    name: vault-auth
    namespace: default
EOF
```

### Configure Kubernetes authentication

in node 1:

```bash
vault auth enable kubernetes
```

in node 2:

```bash
kubectl get secret vault-auth -o go-template='{{ .data.token }}' | base64 --decode > /vagrant/external-vault/token-review-jwt
kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 --decode > /vagrant/external-vault/kube-ca.crt
# kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.server}' > /vagrant/external-vault/kube-ca-host
```

in node 1:

```bash
vault write auth/kubernetes/config \
  token_reviewer_jwt=$(cat /vagrant/external-vault/token-review-jwt) \
  kubernetes_ca_cert=@/vagrant/external-vault/kube-ca.crt \
  kubernetes_host="https://192.168.33.102:16443"
  # kubernetes_host=$(cat /vagrant/external-vault/kube-ca-host)
```

```bash
vault read auth/kubernetes/config
```

```bash
vault policy write devwebapp - <<EOF
path "secret/data/devwebapp/config" {
  capabilities = ["read"]
}
EOF
```

```bash
vault write auth/kubernetes/role/devweb-app \
  bound_service_account_names=internal-app \
  bound_service_account_namespaces=default \
  policies=devwebapp \
  ttl=24h
```

### Install the Vault Helm chart

in node 2:

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault --set "injector.externalVaultAddr=http://external-vault"
```

```bash
NAME                                         READY   STATUS    RESTARTS   AGE
devwebapp-7467bd67b6-6dgmt                   1/1     Running   0          23m
devwebapp-through-service-6dd4b6d699-r9822   1/1     Running   0          15m
vault-agent-injector-957c98b8d-24nlt         1/1     Running   0          15s
```

## Inject secrets into the pod

[patch-02-inject-secrets.yml](patch-02-inject-secrets.yml)

```bash
kubectl patch deployment devwebapp --patch "$(cat patch-02-inject-secrets.yml)"
```

```bash
kubectl exec -it \
  $(kubectl get pod -l app=devwebapp -o jsonpath="{.items[0].metadata.name}") \
  -c app -- cat /vault/secrets/credentials.txt
```

```bash
data: map[password:salsa username:giraffe]
metadata: map[created_time:2019-12-20T18:17:50.930264759Z deletion_time: destroyed:false version:2]
```