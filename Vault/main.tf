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
  path = "CORE0_SITE1"

  type = "kv-v2"

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
# Docker Hub
#
data "vault_generic_secret" "DockerHub" {
  path = "${vault_mount.Terraform.path}/Docker"
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
# GitHub
#
data "vault_generic_secret" "GitHub" {
  path = "${vault_mount.Terraform.path}/GITHUB"
}

#
# MikroTik
#
data "vault_generic_secret" "Home1MikroTik" {
  path = "${vault_mount.Terraform.path}/Home1MikroTik"
}

#
# iDRAC
#
data "vault_generic_secret" "iDRAC" {
  path = "${vault_mount.Terraform.path}/iDRAC"
}


#
# SMTP
#
data "vault_generic_secret" "SMTP" {
  path = "${vault_mount.Terraform.path}/SMTP"
}

#
# Temp KJDev Microsoft Teams
#
data "vault_generic_secret" "MSTeams" {
  path = "${vault_mount.Terraform.path}/MSTeams"
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

  alt_names = ["tink-grpc-cont.service.kjdev", "tink-http-cont.service.kjdev", "tink-grpc-cont.service.dc1.kjdev"]
}

resource "vault_pki_secret_backend_cert" "HegelCert" {
  backend = module.TinkerbellPKI.TLS.Mount.path
  name = module.TinkerbellPKI.TLS.Role.name

  common_name = "hegel"

  alt_names = ["tink-hegel-grpc-cont", "tink-hegel-grpc-cont.service.kjdev"]
}

resource "vault_pki_secret_backend_cert" "TinkRegistryCert" {
  backend = module.TinkerbellPKI.TLS.Mount.path
  name = module.TinkerbellPKI.TLS.Role.name

  common_name = "registry"

  alt_names = ["tink-registry", "tink-registry.service.kjdev", "tink-registry.service.dc1.kjdev"]
}

#
# Pomerium
#
module "Pomerium" {
  source = "./TLS/Template"
}

#
# Pomerium Proxy
# 

resource "vault_pki_secret_backend_cert" "PomeriumProxyCert" {
  backend = module.Pomerium.TLS.Mount.path
  name = module.Pomerium.TLS.Role.name

  common_name = "https.proxy.pomerium.service.kjdev"

  alt_names = ["*.kristianjones.dev", "https.proxy.pomerium.service.dc1.kjdev"]
}


#
# Pomerium Data Broker
#

resource "vault_pki_secret_backend_cert" "PomeriumDataBrokerCert" {
  backend = module.Pomerium.TLS.Mount.path
  name = module.Pomerium.TLS.Role.name

  common_name = "https.databroker.pomerium.service.kjdev"

  alt_names = ["https.databroker.pomerium.service.dc1.kjdev"]
}


#
# Pomerium Authenticate
##

resource "vault_pki_secret_backend_cert" "PomeriumAuthenticateCert" {
  backend = module.Pomerium.TLS.Mount.path
  name = module.Pomerium.TLS.Role.name

  common_name = "https.authenticate.pomerium.service.kjdev"

  alt_names = ["https.authenticate.pomerium.service.dc1.kjdev"]
}


#
# Pomerium Authorize
#

resource "vault_pki_secret_backend_cert" "PomeriumAuthorizeCert" {
  backend = module.Pomerium.TLS.Mount.path
  name = module.Pomerium.TLS.Role.name

  common_name = "https.authorize.pomerium.service.kjdev"

  alt_names = ["https.authorize.pomerium.service.dc1.kjdev"]
}

#
# Pomerium Redis
#

resource "vault_pki_secret_backend_cert" "PomeriumRedisCert" {
  backend = module.Pomerium.TLS.Mount.path
  name = module.Pomerium.TLS.Role.name

  common_name = "redis.pomerium.service.kjdev"

  alt_names = ["redis.pomerium.service.dc1.kjdev"]
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

  alt_names = ["grafana.int.site1.kristianjones.dev", "grafana-cont.service.dc1.kjdev"]
}

#
# Home Assistant
# 

module "HomeAssistant" {
  source = "./TLS/Template"
}

data "vault_generic_secret" "HomeAssistant" {
  path = "${vault_mount.Terraform.path}/HomeAssistant"
}

resource "vault_pki_secret_backend_cert" "HomeAssistantHTTPSCert" {
  backend = module.HomeAssistant.TLS.Mount.path
  name = module.HomeAssistant.TLS.Role.name

  common_name = "homeassistant-https-cont.service.kjdev"

  alt_names = ["hass.int.site1.kristianjones.dev"]
}

#
# Tokens
#

#
# CoreVault
#

data "vault_generic_secret" "CoreVault" {
  path = "${vault_mount.Terraform.path}/CoreVault"
}

#
# Kea DHCP
#

module "DHCP" {
  source = "./TLS/Template"
}

resource "vault_pki_secret_backend_cert" "DHCPServerCert" {
  backend = module.DHCP.TLS.Mount.path
  name = module.DHCP.TLS.Role.name

  common_name = "dhcp.service.kjdev"

  alt_names = ["dhcp.service.dc1.kjdev", "0.dhcp.service.dc1.kjdev", "1.dhcp.service.dc1.kjdev", "2.dhcp.service.dc1.kjdev", "3.dhcp.service.dc1.kjdev", "4.dhcp.service.dc1.kjdev"]
}

#
# Bitwarden
#

module "Bitwarden" {
  source = "./TLS/Template"
}

resource "vault_pki_secret_backend_cert" "BitwardenServerCert" {
  backend = module.Bitwarden.TLS.Mount.path
  name = module.Bitwarden.TLS.Role.name

  common_name = "bitwarden.service.kjdev"

  alt_names = [
    "bitwarden.kristianjones.dev",
    "https.bitwarden.service.dc1.kjdev",
    "bitwarden.service.dc1.kjdev", 
    "https.bitwarden.service.kjdev",
    "wss.bitwarden.service.kjdev",
    "wss.bitwarden.service.dc1.kjdev"
  ]
}

#
# Harbor
#

module "Harbor" {
  source = "./TLS/Template"
}

resource "vault_pki_secret_backend_cert" "HarborCoreServerCert" {
  backend = module.Harbor.TLS.Mount.path
  name = module.Harbor.TLS.Role.name

  common_name = "http.core.harbor.service.kjdev"

  alt_names = ["http.core.harbor.service.dc1.kjdev"]
}

resource "vault_pki_secret_backend_cert" "HarborJobServiceServerCert" {
  backend = module.Harbor.TLS.Mount.path
  name = module.Harbor.TLS.Role.name

  common_name = "http.jobservice.harbor.service.kjdev"

  alt_names = ["http.jobservice.harbor.service.dc1.kjdev"]
}

resource "vault_pki_secret_backend_cert" "HarborPortalServerCert" {
  backend = module.Harbor.TLS.Mount.path
  name = module.Harbor.TLS.Role.name

  common_name = "http.portal.harbor.service.kjdev"

  alt_names = ["http.portal.harbor.service.dc1.kjdev"]
}

resource "vault_pki_secret_backend_cert" "HarborRegistryServerCert" {
  backend = module.Harbor.TLS.Mount.path
  name = module.Harbor.TLS.Role.name

  common_name = "http.registry.harbor.service.kjdev"

  alt_names = ["http.registry.harbor.service.dc1.kjdev"]
}

#
# Prometheus
#

module "PrometheusTLS" {
  source = "./TLS/Template"
}

