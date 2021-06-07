# Usages

## Vagrant up

```bash
vagrant up
```

Done:

```bash
# provision...

PLAY RECAP *********************************************************************
default                    : ok=14   changed=11   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

### Retry Provision

```bash
vagrant provision
```

---

## Unseal Vault

In host: [http://192.168.82.82:8200/ui/](http://192.168.82.82:8200/ui/)

1. Master Key Portion: input key in `"unseal_keys_b64"`
1. Sign in to Vault: input key in `"root_token"`

---

## CURL

### In Host

```bash
export VAULT_ADDR="http://192.168.82.82:8200"
export VAULT_TOKEN="ROOT_TOKEN"
```

```bash
vault status
# or
curl -L http://192.168.82.82:8200/v1/sys/health
```

### In Geust

```bash
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="ROOT_TOKEN"
```

```bash
vault status
# or
curl -L http://127.0.0.1:8200/v1/sys/health
```
