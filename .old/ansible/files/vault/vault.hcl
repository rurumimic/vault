ui = true

api_addr = "https://${PUBLIC_IP}:8200"
cluster_addr = "https://${PRIVATE_IP}:8201"

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_cert_file   = "/opt/vault/tls/tls.crt"
  tls_key_file    = "/opt/vault/tls/tls.key"
}

storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-0"
}


# AWS KMS auto unseal
#seal "awskms" {
#  region = "ap-northeast-2"
#  kms_key_id = "REPLACE-ME"
#}
