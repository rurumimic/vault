# Password Rotation

[sethvargo/vault-secrets-gen](https://github.com/sethvargo/vault-secrets-gen): Plugin

## Vault VM

```bash
export VAULT_ADDR="https://vault"
export VAULT_TOKEN="Root Token"
```

## Install plugin

plugin: `vault-secrets-gen`

```bash
wget https://github.com/sethvargo/vault-secrets-gen/releases/download/v0.1.1/vault-secrets-gen_0.1.1_linux_amd64.zip
unzip vault-secrets-gen_0.1.1_linux_amd64.zip
sudo mkdir /opt/vault/plugins
sudo mv vault-secrets-gen_v0.1.1 /opt/vault/plugins/vault-secrets-gen
sudo setcap cap_ipc_lock=+ep /opt/vault/plugins/vault-secrets-gen
sudo chown -R vault:vault /opt/vault/plugins
export SHA256=$(shasum -a 256 "/opt/vault/plugins/vault-secrets-gen" | cut -d' ' -f1)
```

Register Plugin

```bash
vault plugin register -sha256="${SHA256}" -command="vault-secrets-gen" secret secrets-gen
vault secrets enable -path="gen" -plugin-name="secrets-gen" plugin
```

## Create a password secret engine

```bash
vault secrets enable -version=2 -path=systemcreds/ kv
```

## Policy

```hcl
# Host can create a new password
path "systemcreds/data/linux/*" {
  capabilities = ["create", "update"]
}

# Host can create a new passphrase
path "gen/passphrase" {
  capabilities = ["update"]
}

# Host can create a new password
path "gen/password" {
  capabilities = ["update"]
}

# Admin can read a password
path "systemcreds/*" {
  capabilities = ["list"]
}

path "systemcreds/data/linux/*" {
  capabilities = ["list", "read"]
}
```

---

## Rotate Password

### New Token

```bash
export VAULT_ADDR="https://vault"
export VAULT_TOKEN="Token"

vault token create -period=24h -policy=rotate-linux
```

### Save Token

Save the token at `/etc/environment` on your linux

```bash
# vi /etc/environment
export VAULT_ADDR="https://vault"
export VAULT_TOKEN="s.ZRVb3x0G4GtQh7rdGYyW2MNj"
```

### New user

on your linux, add a user: `messi`

```bash
sudo adduser messi # password ronaldo
```

### Password Refresh

As Root, run [rotate-password.sh](rotate-password.sh).

#### When Failed

`messi`'s password did not changed.

```bash
sudo ./rotate-password.sh messi

./rotate-password.sh: line 28: jq: command not found
(23) Failed writing body
No password supplied
No password supplied
No password supplied
chpasswd: (user messi) pam_chauthtok() failed, error:
Authentication token manipulation error
chpasswd: (line 1, user messi) password not changed
Error: messi's password was stored in Vault but *not* updated locally.
```

### Success

```bash
sudo ./rotate-password.sh messi

messi's password was stored in Vault and updated locally.
```

### Verify

Look `messi`'s password in Vault and Login

```bash
su messi
```
