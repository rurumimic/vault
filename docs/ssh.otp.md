# SSH OTP

Vault users receive OTP from Vault and connect to the remote server.

## vault-ssh-helper

### Install

Install `vault-ssh-helper` on the remote server.

```bash
wget https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_386.zip
unzip vault-ssh-helper_0.2.1_linux_386.zip
sudo mv vault-ssh-helper /usr/local/bin/vault-ssh-helper
```

### `/etc/vault-ssh-helper.d/config.hcl`

- Set the permissions of `vault-ssh-helper`.
- In the test, disable TLS.

```hcl
vault_addr = "https://vault"
ssh_mount_point = "ssh"
tls_skip_verify = true
allowed_roles = "*"
allowed_cidr_list="0.0.0.0/0"
```

### `/etc/pam.d/sshd`

1. Comment out `@include common-auth`.
1. Add the following two lines:

```bash
#@include common-auth
auth requisite pam_exec.so quiet expose_authtok log=/tmp/vaultssh.log /usr/local/bin/vault-ssh-helper -config=/etc/vault-ssh-helper.d/config.hcl
auth optional pam_unix.so not_set_pass use_first_pass nodelay
```

### `/etc/ssh/sshd_config`

Check the options of `sshd_config`.

```bash
ChallengeResponseAuthentication yes
UsePAM yes
PasswordAuthentication no
```

### Restart sshd

```bash
sudo systemctl restart sshd
```

---

## Vault Settings

### Add a policy

Add the following policy:

```hcl
path "ssh/creds/*" {
  capabilities = ["create", "read", "update"]
}
```

### New Vault User

Login as Vault Admin

```bash
export VAULT_ADDR="https://vault"
export VAULT_TOKEN="Root Token"
```

Add a user:

```bash
vault write auth/userpass/users/bob password="password" policies="ssh-otp"
```

---

## SSH OTP issuance and server connection

### Vault Login

Login as `bob`

```bash
export VAULT_ADDR="https://vault"
export VAULT_TOKEN=`vault login -token-only -method=userpass username=bob`
```

### New OTP

```bash
vault write ssh/creds/vampires ip=<your Linux Public IP>
```

### Try SSH

```bash
ssh bob@<your Linux Public IP>
```

---

## Shortcut: SSH OTP issuance and server connection

Shortcut:

```bash
export VAULT_ADDR="https://vault"
export VAULT_TOKEN=`vault login -token-only -method=userpass username=bob`

vault ssh -role vampires -mode otp bob@<your Linux Public IP>
```
