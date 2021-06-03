#!/usr/bin/env bash

_write_ansible_inventory() {
echo "# Hosts" > ./ansible/inventory
printf 'bastion ansible_host=${bastion_ip} ansible_ssh_user=${bastion_user} ansible_ssh_private_key_file=${bastion_private_key} ansible_ssh_extra_args="-o StrictHostKeyChecking=no"\n' >> ./ansible/inventory 

printf '[vault]\n' >> ./ansible/inventory 
PRIVATE_IP=(${private_ip})
for i in "$${!PRIVATE_IP[@]}"; do
  printf 'vault-%s ansible_host=%s ansible_ssh_user=${user} ansible_ssh_extra_args="-o StrictHostKeyChecking=no"\n' "$${i}" "$${PRIVATE_IP[i]}" >> ./ansible/inventory 
done
}

_write_vault_hcl() {
PRIVATE_IP=(${private_ip})
for i in "$${!PRIVATE_IP[@]}"; do
cat << EOF > ./ansible/files/vault-$${i}.hcl
log_level = "Debug"
ui = true
plugin_directory = "/opt/vault/plugins"

listener "tcp" {
  address         = "0.0.0.0:8200"
  # tls_cert_file   = "/opt/vault/tls/tls.crt"
  # tls_key_file    = "/opt/vault/tls/tls.key"
  tls_disable = 1
}

storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-$${i}"
}

api_addr = "http://$${PRIVATE_IP[i]}:8200"
cluster_addr = "http://$${PRIVATE_IP[i]}:8201"

seal "awskms" {
  region = "${region}"
  kms_key_id = "${kms_key_id}"
}
EOF
done
}

_write_ssh_config() {
VAULT_IP=(${private_ip})

cat << EOF > ./ansible/ssh/config
Host bastion
  User ${bastion_user}
  HostName ${bastion_ip}
  Port 22
  IdentityFile ${bastion_private_key}
EOF

for i in "$${!VAULT_IP[@]}"; do
cat << EOF >> ./ansible/ssh/config
Host $${VAULT_IP[i]}
  User ${user}
  Port 22
  IdentityFile ${private_key}
  ProxyCommand ssh -W %h:%p ${bastion_user}@${bastion_ip}

EOF
done
}

_run_ansible() {
  cd ansible && ansible-playbook -i inventory playbook.yml
}

_main() {
    _write_ansible_inventory
    _write_vault_hcl
    _write_ssh_config
    sleep ${sleep-timeout}
    _run_ansible
}

_main "$@"
