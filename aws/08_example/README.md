# Cronjob

## Policy

```json
vault policy write token-manager - <<EOF
path "secret/data/token/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF
```

## Vault Role

```bash
vault write auth/kubernetes/role/token-manager \
    bound_service_account_names=token-manager \
    bound_service_account_namespaces=token-manager \
    policies=token-manager \
    ttl=1h
```


## Run

```bash
kubectl apply -f cronjob.yaml
kubectl delete -f cronjob.yaml
```

```bash
kubectl get cronjob -n token-manager # current job
kubectl get jobs.batch -n token-manager # completed job
kubectl describe cronjob -n token-manager cronjob # Cronjob details
kubectl get po -n token-manager # all Job
```

```bash
kubectl describe jobs.batch -n token-manager cronjob-xxxxxxxxxx
```

Loig

```bash
kubectl logs -n token-manager crotokennjob-xxxxxxxxxx-xxxxx -c job # python log
```
