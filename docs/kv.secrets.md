# Key-Value Secrets

KV Secrets Engine: [Version 2](https://www.vaultproject.io/docs/secrets/kv/kv-v2)

```bash
vault secrets enable -version=2 -path=kv kv
vault secrets list
vault secrets disable kv
```

### Versioning

```bash
vault kv put kv/hello target=world
vault kv put kv/hello greet=hi
vault kv get kv/hello

# ==== Data ====
# Key      Value
# ---      -----
# greet    hi

vault kv get -version=1 kv/hello

# ===== Data =====
# Key       Value
# ---       -----
# target    world
```

### Delete

```bash
vault kv delete kv/hello/
vault kv undelete -versions=2 kv/hello
vault kv get kv/hello
```

### Metadata

```bash
vault kv delete kv/hello/
vault kv list kv/

# Keys
# ----
# hello

vault kv metadata get kv/hello
vault kv metadata delete kv/hello
vault kv list kv/

# No value found at kv/metadata
```
