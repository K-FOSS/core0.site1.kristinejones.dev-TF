terraform {
  required_providers {
    #
    # Hashicorp Vault
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    #
    vault = {
      source = "hashicorp/vault"
      version = "2.24.0"
    }
  }
}

#
# Generic Secrets
#
resource "vault_mount" "Terraform" {
  path        = "CORE0_SITE1"

  type        = "kv-v2"

  description = "Terraform Consul Sync Core Secrets"
}

resource "vault_generic_secret" "TerraformTest" {
  path = "${vault_mount.Terraform.path}/TMP_TEST"

  data_json = jsonencode({
    testing = "HelloWorld"
    helloworld = "Testing123"
  })
}


#
# Tinkerbell
#

resource "vault_generic_secret" "Tinkerbell" {
  path = "${vault_mount.Terraform.path}/Tinkerbell"

  data_json = jsonencode(var.Tinkerbell.Admin)
}

#
# Cloudflare
# 
data "vault_generic_secret" "Cloudflare" {
  path = "${vault_mount.Terraform.path}/Cloudflare"
}

#
# Caddy
#
data "vault_generic_secret" "Caddy" {
  path = "${vault_mount.Terraform.path}/Caddy"
}

#
# Database
#
data "vault_generic_secret" "Database" {
  path = "${vault_mount.Terraform.path}/Database"
}


#
# Bitwarden
#

data "vault_generic_secret" "Bitwarden" {
  path = "keycloak/BitwardenDB"
}

#
# Pomerium
#
# TODO: Move this to Consul KV triggered Terraform Deployment
# 

data "vault_generic_secret" "PomeriumOID" {
  path = "${var.Pomerium.VaultPath}"
}

#
# eJabberD
#

data "vault_generic_secret" "eJabberDOID" {
  path = "${var.eJabberD.OIDVaultPath}"
}

#
# PostgreSQL
#

#
# Minio
#

data "vault_generic_secret" "Minio" {
  path = "${vault_mount.Terraform.path}/Minio"
}

#
# Netbox
#
data "vault_generic_secret" "Netbox" {
  path = "${vault_mount.Terraform.path}/Netbox"
}

#
# NextCloud
#
data "vault_generic_secret" "NextCloud" {
  path = "${vault_mount.Terraform.path}/Nextcloud"
}

#
# TrueNAS NAS
#
data "vault_generic_secret" "NASAuth" {
  path = "keycloak/NASAuth"
}

#
# Tinker Bell TLS
# 
module "TinkerbellPKI" {
  source = "./TLS/Template"
}

resource "vault_pki_secret_backend_cert" "TinkCert" {
  backend = module.TinkerbellPKI.TLS.Mount.path
  name = module.TinkerbellPKI.TLS.Role.name

  common_name = "tinkerbell"

  alt_names = ["tink-grpc-cont.service.kjdev", "tink-http-cont.service.kjdev"]
}

resource "vault_pki_secret_backend_cert" "HegelCert" {
  backend = module.TinkerbellPKI.TLS.Mount.path
  name = module.TinkerbellPKI.TLS.Role.name

  common_name = "hegel"

  alt_names = ["tink-hegel-grpc-cont", "tink-hegel-grpc-cont.service.kjdev"]
}

#
# Pomerium
#
module "Pomerium" {
  source = "./TLS/Template"
}

resource "vault_pki_secret_backend_cert" "PomeriumProxyCert" {
  backend = module.Pomerium.TLS.Mount.path
  name = module.Pomerium.TLS.Role.name

  common_name = "pomerium-proxy-cont.service.kjdev"

  alt_names = ["*.kristianjones.dev"]
}

resource "vault_pki_secret_backend_cert" "PomeriumDataBrokerCert" {
  backend = module.Pomerium.TLS.Mount.path
  name = module.Pomerium.TLS.Role.name

  common_name = "pomerium-databroker-cont.service.kjdev"

  alt_names = []
}

resource "vault_pki_secret_backend_cert" "PomeriumAuthenticateCert" {
  backend = module.Pomerium.TLS.Mount.path
  name = module.Pomerium.TLS.Role.name

  common_name = "pomerium-authenticate-cont.service.kjdev"

  alt_names = []
}

resource "vault_pki_secret_backend_cert" "PomeriumAuthorizeCert" {
  backend = module.Pomerium.TLS.Mount.path
  name = module.Pomerium.TLS.Role.name

  common_name = "pomerium-authorize-cont.service.kjdev"

  alt_names = []
}

resource "vault_pki_secret_backend_cert" "PomeriumRedisCert" {
  backend = module.Pomerium.TLS.Mount.path
  name = module.Pomerium.TLS.Role.name

  common_name = "pomerium-redis-cont.service.kjdev"

  alt_names = []
}

#
# eJabberd
#

module "eJabberD" {
  source = "./TLS/Template"
}

resource "vault_pki_secret_backend_cert" "eJabberDServerCert" {
  backend = module.eJabberD.TLS.Mount.path
  name = module.eJabberD.TLS.Role.name

  common_name = "pomerium-proxy-cont.service.kjdev"

  alt_names = []
}

resource "vault_pki_secret_backend_cert" "eJabberDMQTTServerCert" {
  backend = module.eJabberD.TLS.Mount.path
  name = module.eJabberD.TLS.Role.name

  common_name = "ejabberd-mqtt-cont.service.kjdev"

  alt_names = ["mq.kristianjones.dev"]
}

resource "vault_pki_secret_backend_cert" "eJabberDRedisCert" {
  backend = module.eJabberD.TLS.Mount.path
  name = module.eJabberD.TLS.Role.name

  common_name = "ejabberd-redis.service.kjdev"

  alt_names = []
}

#
# Grafana
#

module "Grafana" {
  source = "./TLS/Template"
}

resource "vault_pki_secret_backend_cert" "GrafanaCert" {
  backend = module.Grafana.TLS.Mount.path
  name = module.Grafana.TLS.Role.name

  common_name = "grafana-cont.service.kjdev"

  alt_names = ["grafana.int.site1.kristianjones.dev"]
}