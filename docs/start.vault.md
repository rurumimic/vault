# Start Vault

- Ansible: [Install package](../aws/01_packer/ansible/playbook.yml)
  - Systemd: [vault.service](../aws/01_packer/ansible/files/vault.service)
- Ansbile: [Start](../aws/03_terraform/ansible/playbook.yml)
  - [Configuration](../aws/03_terraform/ansible/files/vault-0.hcl)
- [Start Vault](../aws/04_vault/README.md)

## on Ubuntu

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install -y vault
```

## Plugin directory

```bash
sudo mkdir /opt/vault/plugins
sudo chown -R vault:vault /opt/vault/plugins
```

## Systemd

[/etc/systemd/system/vault.service](../aws/01_packer/ansible/files/vault.service)

```bash
sudo chmod 644 /etc/systemd/system/vault.service
```

## Vault Configuration

[vault.hcl](../aws/03_terraform/ansible/files/vault-0.hcl)

```bash
sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl
```

## Development server start

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

## Production server start

```bash
sudo systemctl start vault
sudo systemctl enabled vault
```

### Init Vault

- [Start Vault](../aws/04_vault/README.md)

```bash
vault operator init -format=json > vault.keys.json
```

```bash
chmod 600 vault.keys.json
```

```bash
vault status
```
