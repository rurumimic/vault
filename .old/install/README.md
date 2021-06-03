# Install

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install -y vault
```

## Dev Server

```bash
vault server -dev
```

```bash
==> Vault server configuration:

      Api Address: http://127.0.0.1:8200
              Cgo: disabled
  Cluster Address: https://127.0.0.1:8201
      Go Version: go1.15.4
      Listener 1: tcp (addr: "127.0.0.1:8200", cluster address: "127.0.0.1:8201", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
        Log Level: info
            Mlock: supported: true, enabled: false
    Recovery Mode: false
          Storage: inmem
          Version: Vault v1.6.1
      Version Sha: 6d2db3f033e02e70202bef9ec896360062b88b03

You may need to set the following environment variable:

    $ export VAULT_ADDR='http://127.0.0.1:8200'

The unseal key and root token are displayed below in case you want to
seal/unseal the Vault or re-authenticate.

Unseal Key: Ir/U2wbq/NGeXk+QB1kr08oXqNGWeCB3p2a3Q0r4e54=
Root Token: s.81LsBQ5sAqyC9yKCJKiOtDLY
```

Save the unseal key somewhere.

### Verify the server is running

Open a new terminal session

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN="s.81LsBQ5sAqyC9yKCJKiOtDLY"

vault status
```

```bash
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.6.1
Storage Type    inmem
Cluster Name    vault-cluster-fd42e993
Cluster ID      d1d93378-f765-5ee6-8f0a-f0624041b3e0
HA Enabled      false
```

---

## Secrets

### Key-Value Engine

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

---

## Deploy

1. terminate the dev server
1. Unset `VAULT_TOKEN`: `unset VAULT_TOKEN`

### Requirements

[day 1 consul](https://learn.hashicorp.com/tutorials/vault/production-hardening?in=vault/day-one-consul)

```bash
swapoff -a
```

### Configuring Vault

1. Edit [config.hcl](config.hcl)
1. Create the `vault/data` directory for the storage backend: `mkdir -p vault/data`
1. Start a Vault server: `vault server -config=config.hcl`
1. Go to [http://192.168.33.101:8200/ui](http://192.168.33.101:8200/ui)
1. Select **Create a new Raft cluster** and click **Next**
1. Enter `5` in the **Key shares** and `3` in the **Key threshold** text fields
1. Click **Initialize**
1. Select **Download key**
1. Click **Continue to Unseal** to proceed
1. Open the downloaded [file](keys.json)
1. Copy one of the `keys` (not `keys_base64`) and enter it in the **Master Key Portion** field. Click **Unseal** to proceed.
1. Copy the `root_token` and enter its value in the **Token** field. Click **Sign in**.
