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

    #
    # TLS
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/tls/latest/docs
    #
    tls = {
      source = "hashicorp/tls"
      version = "3.1.0"
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
# AAA
# 

#
# Authentik
#

#
# Authentik LDAP
#

data "vault_generic_secret" "LDAP" {
  path = "${vault_mount.Terraform.path}/LDAP"
}

#
# Bitwarden
#

data "vault_generic_secret" "BitwardenCore" {
  path = "${vault_mount.Terraform.path}/Bitwarden"
}

#
# Teleport
#

data "vault_generic_secret" "Teleport" {
  path = "${vault_mount.Terraform.path}/Teleport"
}

#
# Communications
#

#
# Mattermost
#

data "vault_generic_secret" "Mattermost" {
  path = "${vault_mount.Terraform.path}/Mattermost"
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
# Pomerium
#

resource "tls_private_key" "PomeriumSigningKey" {
  algorithm = "ECDSA"

  ecdsa_curve = "P256"
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
# GitLab
#
data "vault_generic_secret" "GitLab" {
  path = "${vault_mount.Terraform.path}/GitLab"
}

#
# eJabberD
#
data "vault_generic_secret" "eJabberD" {
  path = "${vault_mount.Terraform.path}/eJabberD"
}

#
# Misc
#

data "vault_generic_secret" "Ivatar" {
  path = "${vault_mount.Terraform.path}/Ivatar"
}


#
# HomeAssistant
#

data "vault_generic_secret" "HASS" {
  path = "${vault_mount.Terraform.path}/HASS"
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

#
# Network
#

#
# ENMS
#

data "vault_generic_secret" "ENMS" {
  path = "${vault_mount.Terraform.path}/ENMS"
}

#
# Business
#

#
# OpenProject
#

data "vault_generic_secret" "OpenProject" {
  path = "${vault_mount.Terraform.path}/OpenProject"
}

#
# Vikunja
#

data "vault_generic_secret" "Vikunja" {
  path = "${vault_mount.Terraform.path}/Vikunja"
}

#
# Outline
#

data "vault_generic_secret" "Outline" {
  path = "${vault_mount.Terraform.path}/Outline"
}

#
# Servers
#

data "vault_generic_secret" "Rancher" {
  path = "${vault_mount.Terraform.path}/Rancher"
}

data "vault_generic_secret" "HashUI" {
  path = "${vault_mount.Terraform.path}/HashUI"
}

#
# TLS Certificates
#

#
# AAA
#

#
# Teleport
#

module "Teleport" {
  source = "./TLS/Template"
}

#
# Teleport ETCD
#

resource "vault_pki_secret_backend_cert" "TeleportETCDCert" {
  backend = module.Teleport.TLS.Mount.path
  name = module.Teleport.TLS.Role.name

  common_name = "etcd.teleport.service.dc1.kjdev"

  alt_names = ["etcd.teleport.service.kjdev", "etcd.teleport.service.dc1.kjdev", "*.etcd.teleport.service.dc1.kjdev", "*.etcd.teleport.service.kjdev", "*.peer.etcd.teleport.service.dc1.kjdev", "*.peer.etcd.teleport.service.kjdev"]
}

#
# Teleport Proxy
#

resource "vault_pki_secret_backend_cert" "TeleportProxyCert" {
  backend = module.Teleport.TLS.Mount.path
  name = module.Teleport.TLS.Role.name

  common_name = "https.proxy.teleport.service.dc1.kjdev"

  alt_names = ["proxy.access.kristianjones.dev", "https.proxy.teleport.service.kjdev"]
}

#
# Teleport Auth
# 

resource "vault_pki_secret_backend_cert" "TeleportAuthCert" {
  backend = module.Teleport.TLS.Mount.path
  name = module.Teleport.TLS.Role.name

  common_name = "https.auth.teleport.service.dc1.kjdev"

  alt_names = ["auth.access.kristianjones.dev", "https.auth.teleport.service.kjdev"]
}

#
# Teleport Tunnel
#

resource "vault_pki_secret_backend_cert" "TeleportTunnelCert" {
  backend = module.Teleport.TLS.Mount.path
  name = module.Teleport.TLS.Role.name

  common_name = "https.tunnel.teleport.service.dc1.kjdev"

  alt_names = ["tunnel.access.kristianjones.dev", "https.tunnel.teleport.service.kjdev"]
}

#
# Teleport Kube
#

resource "vault_pki_secret_backend_cert" "TeleportKubeCert" {
  backend = module.Teleport.TLS.Mount.path
  name = module.Teleport.TLS.Role.name

  common_name = "https.kube.teleport.service.dc1.kjdev"

  alt_names = ["kube.access.kristianjones.dev", "https.kube.teleport.service.kjdev"]
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

  alt_names = ["*", "*.kristianjones.dev", "*.int.site1.kristianjones.dev", "kjmedia.stream", "*.kjmedia.stream", "mylogin.space", "*.int.mylogin.space", "*.mylogin.space", "https.proxy.pomerium.service.dc1.kjdev"]
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

  common_name = "mqtt.ejabberd.service.kjdev"

  alt_names = ["mq.kristianjones.dev"]
}

resource "vault_pki_secret_backend_cert" "eJabberDRedisCert" {
  backend = module.eJabberD.TLS.Mount.path
  name = module.eJabberD.TLS.Role.name

  common_name = "redis.ejabberd.service.kjdev"

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
# Inventory
#

#
# DCIM
#

#
# Netbox
#

# module "Netbox" {
#   source = "./TLS/Template"
# }

# data "vault_generic_secret" "NetboxServer" {
#   path = "${vault_mount.Terraform.path}/HomeAssistant"
# }

# resource "vault_pki_secret_backend_cert" "HomeAssistantHTTPSCert" {
#   backend = module.HomeAssistant.TLS.Mount.path
#   name = module.HomeAssistant.TLS.Role.name

#   common_name = "homeassistant-https-cont.service.kjdev"

#   alt_names = ["hass.int.site1.kristianjones.dev"]
# }


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
# Performance
#

#
# Sentry
#

module "Sentry" {
  source = "./TLS/Template"
}

#
# Sentry Redis
#

resource "vault_pki_secret_backend_cert" "SentryRedisCert" {
  backend = module.Sentry.TLS.Mount.path
  name = module.Sentry.TLS.Role.name

  common_name = "redis.sentry.service.kjdev"

  alt_names = ["redis.sentry.service.dc1.kjdev"]
}

#
# Sentry Server
#

resource "vault_pki_secret_backend_cert" "SentryServerCert" {
  backend = module.Sentry.TLS.Mount.path
  name = module.Sentry.TLS.Role.name

  common_name = "https.server.sentry.service.kjdev"

  alt_names = ["https.server.sentry.service.dc1.kjdev"]
}

#
# Registry
#

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

  common_name = "https.portal.harbor.service.kjdev"

  alt_names = ["https.portal.harbor.service.dc1.kjdev", "http.portal.harbor.service.kjdev", "http.portal.harbor.service.dc1.kjdev"]
}

resource "vault_pki_secret_backend_cert" "HarborRegistryServerCert" {
  backend = module.Harbor.TLS.Mount.path
  name = module.Harbor.TLS.Role.name

  common_name = "https.registry.harbor.service.kjdev"

  alt_names = ["https.registry.harbor.service.dc1.kjdev"]
}

resource "vault_pki_secret_backend_cert" "HarborGitLabRegistryServerCert" {
  backend = module.Harbor.TLS.Mount.path
  name = module.Harbor.TLS.Role.name

  common_name = "https.gitlabregistry.harbor.service.kjdev"

  alt_names = ["https.gitlabregistry.harbor.service.dc1.kjdev"]
}

resource "vault_pki_secret_backend_cert" "HarborGitLabRegistryCTLServerCert" {
  backend = module.Harbor.TLS.Mount.path
  name = module.Harbor.TLS.Role.name

  common_name = "https.gitlabregistrycontroller.harbor.service.kjdev"

  alt_names = ["https.gitlabregistrycontroller.harbor.service.dc1.kjdev"]
}

resource "vault_pki_secret_backend_cert" "HarborRegistryCTLServerCert" {
  backend = module.Harbor.TLS.Mount.path
  name = module.Harbor.TLS.Role.name

  common_name = "https.registrycontroller.harbor.service.kjdev"

  alt_names = ["https.registrycontroller.harbor.service.dc1.kjdev"]
}

resource "vault_pki_secret_backend_cert" "HarborExporterServerCert" {
  backend = module.Harbor.TLS.Mount.path
  name = module.Harbor.TLS.Role.name

  common_name = "https.exporter.harbor.service.kjdev"

  alt_names = ["https.exporter.harbor.service.dc1.kjdev"]
}

resource "vault_pki_secret_backend_cert" "HarborChartMuseumServerCert" {
  backend = module.Harbor.TLS.Mount.path
  name = module.Harbor.TLS.Role.name

  common_name = "https.chartmuseum.harbor.service.kjdev"

  alt_names = ["https.chartmuseum.harbor.service.dc1.kjdev", "https.charts.harbor.service.dc1.kjdev", "charts.registry.kristianjones.dev"]
}

#
# Search
#

module "OpenSearch" {
  source = "./TLS/Template"
}

#
# TODO: Automate this, along with cert files, and configs for OpenSearch cluster generation
#

#
# Coordinator
#

# Coordinator0
resource "vault_pki_secret_backend_cert" "OpenSearchCoordinator0Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "0.https.coordinator.opensearch.service.kjdev"

  alt_names = ["0.https.coordinator.opensearch.service.dc1.kjdev"]

  private_key_format = "pkcs8"
}


# Coordinator1
resource "vault_pki_secret_backend_cert" "OpenSearchCoordinator1Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "1.https.coordinator.opensearch.service.kjdev"

  alt_names = ["1.https.coordinator.opensearch.service.dc1.kjdev"]

  private_key_format = "pkcs8"
}

# Coordinator2
resource "vault_pki_secret_backend_cert" "OpenSearchCoordinator2Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "2.https.coordinator.opensearch.service.kjdev"

  alt_names = ["2.https.coordinator.opensearch.service.dc1.kjdev"]

  private_key_format = "pkcs8"
}

#
# Ingest
#

# Ingest0
resource "vault_pki_secret_backend_cert" "OpenSearchIngest0Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "0.https.ingest.opensearch.service.kjdev"

  alt_names = ["0.https.ingest.opensearch.service.dc1.kjdev"]

  private_key_format = "pkcs8"
}

# Ingest1
resource "vault_pki_secret_backend_cert" "OpenSearchIngest1Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "1.https.ingest.opensearch.service.kjdev"

  alt_names = ["1.https.ingest.opensearch.service.dc1.kjdev"]

  private_key_format = "pkcs8"
}

# Ingest2
resource "vault_pki_secret_backend_cert" "OpenSearchIngest2Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "2.https.ingest.opensearch.service.kjdev"

  alt_names = ["2.https.ingest.opensearch.service.dc1.kjdev"]

  private_key_format = "pkcs8"
}

#
# Main
#

# Main0
resource "vault_pki_secret_backend_cert" "OpenSearchMain0Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "0.https.master.opensearch.service.kjdev"

  alt_names = ["0.https.master.opensearch.service.dc1.kjdev"]

  private_key_format = "pkcs8"
}

# Main1
resource "vault_pki_secret_backend_cert" "OpenSearchMain1Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "1.https.master.opensearch.service.kjdev"

  alt_names = ["1.https.master.opensearch.service.dc1.kjdev"]

  private_key_format = "pkcs8"
}

# Main2
resource "vault_pki_secret_backend_cert" "OpenSearchMain2Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "2.https.master.opensearch.service.kjdev"

  alt_names = ["2.https.master.opensearch.service.dc1.kjdev"]

  private_key_format = "pkcs8"
}

#
# Data
#

# Data0
resource "vault_pki_secret_backend_cert" "OpenSearchData0Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "0.https.data.opensearch.service.kjdev"

  alt_names = ["0.https.data.opensearch.service.dc1.kjdev", "kjdev-opensearch-data0-custom-app.ix-kjdev-opensearch-data0.svc.cluster.local"]

  private_key_format = "pkcs8"
}

# Data1
resource "vault_pki_secret_backend_cert" "OpenSearchData1Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "1.https.data.opensearch.service.kjdev"

  alt_names = ["1.https.data.opensearch.service.dc1.kjdev", "kjdev-opensearch-data1-custom-app.ix-kjdev-opensearch-data1.svc.cluster.local"]

  private_key_format = "pkcs8"
}


# Data2
resource "vault_pki_secret_backend_cert" "OpenSearchData2Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "2.https.data.opensearch.service.kjdev"

  alt_names = ["2.https.data.opensearch.service.dc1.kjdev", "kjdev-opensearch-data2-custom-app.ix-kjdev-opensearch-data2.svc.cluster.local"]

  private_key_format = "pkcs8"
}

# Data3
resource "vault_pki_secret_backend_cert" "OpenSearchData3Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "3.https.data.opensearch.service.kjdev"

  alt_names = ["3.https.data.opensearch.service.dc1.kjdev", "kjdev-opensearch-data3-custom-app.ix-kjdev-opensearch-data3.svc.cluster.local"]

  private_key_format = "pkcs8"
}

# Data4
resource "vault_pki_secret_backend_cert" "OpenSearchData4Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "4.https.data.opensearch.service.kjdev"

  alt_names = ["4.https.data.opensearch.service.dc1.kjdev", "kjdev-opensearch-data4-custom-app.ix-kjdev-opensearch-data4.svc.cluster.local"]

  private_key_format = "pkcs8"
}

# Data5
resource "vault_pki_secret_backend_cert" "OpenSearchData5Cert" {
  backend = module.OpenSearch.TLS.Mount.path
  name = module.OpenSearch.TLS.Role.name

  common_name = "5.https.data.opensearch.service.kjdev"

  alt_names = ["5.https.data.opensearch.service.dc1.kjdev", "kjdev-opensearch-data5-custom-app.ix-kjdev-opensearch-data5.svc.cluster.local"]

  private_key_format = "pkcs8"
}

#
# Security
#



#
# Prometheus
#

module "PrometheusTLS" {
  source = "./TLS/Template"
}

#
# Development
#

#
# GitLab
#

#
# OpenID
#

resource "tls_private_key" "GitLabOpenIDSigningKey" {
  algorithm = "RSA"
}

#
# mTLS
#

module "GitLabTLS" {
  source = "./TLS/Template"
}

resource "vault_pki_secret_backend_cert" "GitLabWebServicesCert" {
  backend = module.GitLabTLS.TLS.Mount.path
  name = module.GitLabTLS.TLS.Role.name

  common_name = "https.webservices.gitlab.service.kjdev"

  alt_names = ["https.webservices.gitlab.service.dc1.kjdev", "https.webservice.gitlab.service.dc1.kjdev", "https.webservice.gitlab.service.kjdev"]
}

resource "vault_pki_secret_backend_cert" "GitLabWorkHorseCert" {
  backend = module.GitLabTLS.TLS.Mount.path
  name = module.GitLabTLS.TLS.Role.name

  common_name = "https.workhorse.gitlab.service.kjdev"

  alt_names = ["https.workhorse.gitlab.service.dc1.kjdev"]
}