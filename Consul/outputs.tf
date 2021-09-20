output "Patroni" {
  value = {
    Hostname = "core0.site1.kristianjones.dev"
    Port = 8500


    Prefix = locals.Patroni.Prefix
    ServiceName = locals.Patroni.ServiceName

    Token = data.consul_acl_token_secret_id.PatroniToken.secret_id
  }
}