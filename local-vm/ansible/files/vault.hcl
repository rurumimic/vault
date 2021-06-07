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
  node_id = "vault"
}

api_addr = "http://192.168.82.82:8200"
cluster_addr = "http://192.168.82.82:8201"
