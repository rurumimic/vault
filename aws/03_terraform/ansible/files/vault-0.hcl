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
  node_id = "vault-0"
}

api_addr = "http://xxx.xxx.xxx.xxx:8200"
cluster_addr = "http://xxx.xxx.xxx.xxx:8201"

seal "awskms" {
  region = "ap-northeast-2"
  kms_key_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
