# Start a Vault

## Connect to SSH

```bash
ssh-add ~/.ssh/bastion.pem
ssh-add ~/.ssh/vault.pem
ssh -J ec2-user@xxx.xxx.xxx.xxx ubuntu@xxx.xxx.xxx.xxx
```

### Vault Status

```bash
export VAULT_ADDR=http://127.0.0.1:8200
vault status
```

```bash
Key                      Value
---                      -----
Recovery Seal Type       awskms
Initialized              false
Sealed                   true
Total Recovery Shares    0
Threshold                0
Unseal Progress          0/0
Unseal Nonce             n/a
Version                  1.7.2
Storage Type             raft
HA Enabled               true
```

### Vault Init

Store Recovery Key And Root Token in `vault.keys.json`

```bash
vault operator init -recovery-shares=5 -recovery-threshold=3 -format=json > vault.keys.json
chmod 600 vault.keys.json
```

### Vault Status

```bash
vault status
```

```bash
Key                      Value
---                      -----
Recovery Seal Type       shamir
Initialized              true
Sealed                   false
Total Recovery Shares    5
Threshold                3
Version                  1.7.2
Storage Type             raft
Cluster Name             vault-cluster-xxxxxxxx
Cluster ID               xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
HA Enabled               true
HA Cluster               https://xxx.xxx.xxx.xxx:8201
HA Mode                  active
Active Since             2021-05-31T00:00:00.000000000Z
Raft Committed Index     38
Raft Applied Index       38
```
