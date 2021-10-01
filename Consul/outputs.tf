output "Patroni" {
  value = {
    Hostname = "consul.service.kjdev"
    Port = 8500


    Prefix = local.Patroni.Prefix
    ServiceName = local.Patroni.ServiceName

    Token = data.consul_acl_token_secret_id.PatroniToken.secret_id
  }
}

#
# Grafana Cortex 
#
output "Cortex" {
  value = {
    Hostname = "consul.service.kjdev"
    Port = 8500


    Prefix = local.Cortex.Prefix

    Token = data.consul_acl_token_secret_id.CortexToken.secret_id
  }
}

#
# Grafana Loki
#
output "Loki" {
  value = {
    Hostname = "consul.service.kjdev"
    Port = 8500


    Prefix = local.Loki.Prefix

    Token = data.consul_acl_token_secret_id.LokiToken.secret_id
  }
}

#
# Grafana Tempo
#
output "Tempo" {
  value = {
    Hostname = "consul.service.kjdev"
    Port = 8500


    Prefix = local.Tempo.Prefix

    Token = data.consul_acl_token_secret_id.TempoToken.secret_id
  }
}



output "Pomerium" {
  value = {
    OIDVaultPath = data.consul_key_prefix.PomeriumOID.subkeys["vault_path"]
  }
}