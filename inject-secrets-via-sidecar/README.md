# Inject secrets via local helm sidecar

- [Injecting Secrets into Kubernetes Pods via Vault Helm Sidecar](https://learn.hashicorp.com/tutorials/vault/kubernetes-sidecar?in=vault/kubernetes)

```bash
minikube start
```

Running a Vault server in development is automatically initialized and unsealed:

```bash
cd inject-secrets-via-sidecar
helm install vault hashicorp/vault --set "server.dev.enabled=true"
```

## Set a secret

```bash
kubectl exec -it vault-0 -- /bin/sh
vault secrets enable -path=internal kv-v2
vault kv put internal/database/config username="db-readonly-username" password="db-secret-password"
vault kv get internal/database/config
```

## Configure Kubernetes authentication

```bash
vault auth enable kubernetes
```

```bash
vault write auth/kubernetes/config \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

Policy:

```bash
vault policy write internal-app - <<EOF
path "internal/data/database/config" {
  capabilities = ["read"]
}
EOF
```

Auth role:

```bash
vault write auth/kubernetes/role/internal-app \
  bound_service_account_names=internal-app \
  bound_service_account_namespaces=default \
  policies=internal-app \
  ttl=24h
```

```bash
exit
```

## Define a service account

```bash
kubectl get serviceaccounts

NAME                   SECRETS   AGE
default                1         6h36m
vault                  1         5m19s
vault-agent-injector   1         5m19s
```

[service-account-internal-app.yml](service-account-internal-app.yml)

```bash
kubectl apply --filename service-account-internal-app.yml
```

```bash
kubectl get serviceaccounts

NAME                   SECRETS   AGE
default                1         6h38m
internal-app           1         12s
vault                  1         7m25s
vault-agent-injector   1         7m25s
```

## Launch an application

[deployment-orgchart.yml](deployment-orgchart.yml)

```bash
kubectl apply --filename deployment-orgchart.yml
```

```bash
kubectl get pods

NAME                                  READY   STATUS    RESTARTS   AGE
orgchart-7457f8489d-wx4z7             1/1     Running   0          11s
vault-0                               1/1     Running   0          12m
vault-agent-injector-c54c5747-kvm9k   1/1     Running   0          12m
```

Verify that no secrets are written to the orgchart container in the orgchart pod:

```bash
kubectl exec \
    $(kubectl get pod -l app=orgchart -o jsonpath="{.items[0].metadata.name}") \
    --container orgchart -- ls /vault/secrets

ls: /vault/secrets: No such file or directory
command terminated with exit code 1
```

## Inject secrets into the pod

[patch-inject-secrets.yml](patch-inject-secrets.yml)

```bash
kubectl patch deployment orgchart --patch "$(cat patch-inject-secrets.yml)"
```

`agent-inject-secret-FILEPATH` prefixes the path of the file, `database-config.txt` written to the `/vault/secrets` directory. The value is the path to the secret defined in Vault.

```bash
kubectl get pod

NAME                                  READY   STATUS     RESTARTS   AGE
orgchart-7457f8489d-wx4z7             1/1     Running    0          37m
orgchart-798cbc6c76-zk6mz             0/2     Init:0/1   0          34s
vault-0                               1/1     Running    0          49m
vault-agent-injector-c54c5747-kvm9k   1/1     Running    0          49m
```

This new pod now launches two containers. The application container, named `orgchart`, and the Vault Agent container, named `vault-agent`.

```bash
kubectl exec \
  $(kubectl get pod -l app=orgchart -o jsonpath="{.items[0].metadata.name}") \
  --container orgchart -- cat /vault/secrets/database-config.txt

data: map[password:db-secret-password username:db-readonly-username]
metadata: map[created_time:2021-01-22T05:33:29.352561601Z deletion_time: destroyed:false version:1]
```

## Apply a template to the injected secrets

[patch-inject-secrets-as-template.yml](patch-inject-secrets-as-template.yml)

```bash
kubectl patch deployment orgchart --patch "$(cat patch-inject-secrets-as-template.yml)"
```

```bash
kubectl exec \
  $(kubectl get pod -l app=orgchart -o jsonpath="{.items[0].metadata.name}") \
  -c orgchart -- cat /vault/secrets/database-config.txt

postgresql://db-readonly-username:db-secret-password@postgres:5432/wizard
```

## Pod with annotations

[pod-payroll.yml](pod-payroll.yml)

```bash
kubectl apply --filename pod-payroll.yml
```

```bash
kubectl exec \
  payroll \
  --container payroll -- cat /vault/secrets/database-config.txt

postgresql://db-readonly-username:db-secret-password@postgres:5432/wizard
```

## Secrets are bound to the service account

[deployment-website.yml](deployment-website.yml)

```bash
kubectl apply --filename deployment-website.yml
```

```bash
kubectl logs \
  $(kubectl get pod -l app=website -o jsonpath="{.items[0].metadata.name}") \
  --container vault-agent-init
```

```log
2021-01-22T05:41:56.676Z [INFO]  auth.handler: authenticating
2021-01-22T05:41:56.682Z [ERROR] auth.handler: error authenticating: error="Error making API request.

URL: PUT http://vault.default.svc:8200/v1/auth/kubernetes/login
Code: 500. Errors:

* service account name not authorized" backoff=1.111480759
```

patch:

```bash
kubectl patch deployment website --patch "$(cat patch-website.yml)"
```

```bash
kubectl exec \
  $(kubectl get pod -l app=website -o jsonpath="{.items[0].metadata.name}") \
  --container website -- cat /vault/secrets/database-config.txt; echo

postgresql://db-readonly-username:db-secret-password@postgres:5432/wizard
```

## Secrets are bound to the namespace

```bash
kubectl create namespace offsite
kubectl config set-context --current --namespace offsite
```

```bash
kubectl config get-contexts

CURRENT   NAME       CLUSTER            AUTHINFO   NAMESPACE
*         microk8s   microk8s-cluster   admin      offsite
```

```bash
kubectl get ns

NAME              STATUS   AGE
kube-system       Active   21m
kube-public       Active   21m
kube-node-lease   Active   21m
default           Active   21m
offsite           Active   2m39s
```

create a service account in `offsite` namespace:

```bash
kubectl apply --filename service-account-internal-app.yml
```

[deployment-issues.yml](deployment-issues.yml)

```bash
kubectl apply --filename deployment-issues.yml
```

```bash
kubectl get pods

NAME                      READY   STATUS     RESTARTS   AGE
issues-5dd5bfc8d6-nw2pb   0/2     Init:0/1   0          16s
```

```bash
kubectl logs \
  $(kubectl get pod -l app=issues -o jsonpath="{.items[0].metadata.name}") \
  --container vault-agent-init
```

```log
2021-01-22T05:50:01.853Z [INFO]  auth.handler: authenticating
2021-01-22T05:50:01.857Z [ERROR] auth.handler: error authenticating: error="Error making API request.

URL: PUT http://vault.default.svc:8200/v1/auth/kubernetes/login
Code: 500. Errors:

* namespace not authorized" backoff=2.20079822
```

```bash
kubectl exec --namespace default -it vault-0 -- /bin/sh

vault write auth/kubernetes/role/offsite-app \
    bound_service_account_names=internal-app \
    bound_service_account_namespaces=offsite \
    policies=internal-app \
    ttl=24h

exit
```

[patch-issues.yml](patch-issues.yml)

```bash
kubectl patch deployment issues --patch "$(cat patch-issues.yml)"
```

```bash
kubectl get pods

NAME                      READY   STATUS        RESTARTS   AGE
issues-8c8c7dbdc-8s57h    2/2     Running       0          5s
issues-5dd5bfc8d6-nw2pb   0/2     Terminating   0          2m47s
```

```bash
kubectl exec \
  $(kubectl get pod -l app=issues -o jsonpath="{.items[0].metadata.name}") \
  --container issues -- cat /vault/secrets/database-config.txt; echo

postgresql://db-readonly-username:db-secret-password@postgres:5432/wizard
```

## Clean up

```bash
kubectl delete --filename service-account-internal-app.yml
kubectl delete --filename deployment-orgchart.yml
helm uninstall vault
```
