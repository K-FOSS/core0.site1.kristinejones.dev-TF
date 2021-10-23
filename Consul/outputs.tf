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

#
# CoreDNS
#
output "DNS" {
  value = {
    Hostname = "consul.service.kjdev"
    Port = 8500

    Token = data.consul_acl_token_secret_id.DNSToken.secret_id
  }
}

#
# Consul Backups
#
output "Backups" {
  value = {
    Hostname = "consul.service.kjdev"
    Port = 8500

    Token = data.consul_acl_token_secret_id.BackupsToken.secret_id
  }
}


#
# Pomerium Ingress
#

output "Pomerium" {
  value = {
    OIDVaultPath = data.consul_key_prefix.PomeriumOID.subkeys["vault_path"]
  }
}

#
# eJabberD
#
output "eJabberD" {
  value = {
    OIDVaultPath = data.consul_key_prefix.eJabberDOID.subkeys["vault_path"]
  }
}