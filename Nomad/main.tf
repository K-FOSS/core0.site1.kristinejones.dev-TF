terraform {
  required_providers {
    #
    # Hashicorp Vault
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    #
    nomad = {
      source = "hashicorp/nomad"
      version = "1.4.15"
    }

    #
    # Randomness
    #
    # TODO: Find a way to best improve true randomness?
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/random/latest/docs
    #
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "nomad" {
  address = "http://core0.site1.kristianjones.dev:4646"
  region  = "global"
}

#
# CSI
#

resource "nomad_job" "Storage" {
  jobspec = templatefile("${path.module}/Jobs/Storage/Controller.hcl", {
    CSI_CONFIG = templatefile("${path.module}/Jobs/Storage/Configs/CSI.yaml", var.Storage)
  })
}

resource "nomad_job" "CSIStorage" {
  jobspec = templatefile("${path.module}/Jobs/Storage/Node.hcl", {
    CSI_CONFIG = templatefile("${path.module}/Jobs/Storage/Configs/CSI.yaml", var.Storage)
  })
}

#
# Pomerium
#

module "Pomerium" {
  source = "./Jobs/Pomerium"

  OpenID = var.Pomerium.OpenID

  Secrets = var.Pomerium.Secrets

  Services = var.Pomerium.Services

  TLS = var.Pomerium.TLS
}


#
# Bitwarden
#
resource "nomad_job" "Nomad" {
  jobspec = templatefile("${path.module}/Jobs/Bitwarden/Bitwarden.hcl", {
    Database = var.Bitwarden.Database
  })
}

#
# Grafana
#

module "Grafana" {
  source = "./Jobs/Grafana"

  Database = var.Grafana.Database

  TLS = var.Grafana.TLS
}

#
# AAA
#

#
# Authentik
#

resource "random_string" "AuthentikSecretKey" {
  length           = 10
  special          = false
}

resource "nomad_job" "Authentik" {
  jobspec = templatefile("${path.module}/Jobs/Authentik/main.hcl", {
    Database = var.Authentik.Database
    SECRET_KEY = "${random_string.AuthentikSecretKey.result}"
  })
}


#
# Caddy Web Ingress
#

module "Web" {
  source = "./Jobs/Web"

  Consul = var.Ingress.Consul

  CloudFlare = var.Ingress.Cloudflare

  Pomerium = {
    CA = var.Pomerium.TLS.CA
  }
}

module "CoTurn" {
  source = "./Jobs/CoTurn"

  Realm = "kristianjones.dev"

  Database = var.CoTurn.Database
}

#
# Grafana
#

# resource "nomad_job" "Grafana" {
#   jobspec = templatefile("${path.module}/Jobs/Web/Web.hcl", {
#     Consul = var.Ingress.Consul

#     CONFIG = templatefile("${path.module}/Jobs/Grafana/Configs/Grafana.ini", { 
#       Database = var.
#     }),
#   })
# }

#
# Patroni
#

resource "nomad_volume" "Patroni" {
  type                  = "csi"
  plugin_id             = "truenas"
  volume_id             = "patronidata-vol"
  name                  = "patronidata-vol"
  external_id           = "test-vol"

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }

  deregister_on_destroy = true

  mount_options {
    fs_type = "nfs"
    mount_flags = ["nolock"]
  }

  context = {
    node_attach_driver = "nfs"
    provisioner_driver = "freenas-nfs"
    server             = "172.16.51.21"
    share              = "/mnt/Site1.NAS1.Pool1/CSI/vols/test-vol"
  }
}

resource "nomad_job" "Patroni" {
  jobspec = templatefile("${path.module}/Jobs/Patroni/main.hcl", {
    Volume = nomad_volume.Patroni
    CONFIG =  templatefile("${path.module}/Jobs/Patroni/Configs/Patroni.yaml", var.Patroni)
  })
}

#
# Database Web Interfaces
#

# locals {
#   Databases = tomap({
#     Keycloak = {
#       target = "distributor"
#       replicas = 3
#       name = "Distributor"
#     },
#     Ingester = {
#       target = "ingester"
#       replicas = 3
#       name = "Ingester"
#     }, 
#   })
# }

# resource "nomad_job" "DatabaseWeb" {
#   for_each = local.Databases

#   jobspec = templatefile("${path.module}/Jobs/DatabaseWeb/main.hcl", {
#     Consul = var.Ingress.Consul

#     CONFIG = templatefile("${path.module}/Jobs/Grafana/Configs/Grafana.ini", { 
#       Database = var.
#     }),
#   })
# }


#
# Metrics
#  

module "Metrics" {
  source = "./Jobs/Metrics"

  Loki = var.Metrics.Loki

  Cortex = var.Metrics.Cortex

  Tempo = var.Metrics.Tempo

  Prometheus = var.Metrics.Prometheus
}



module "NetboxJob" {
  source = "./Jobs/Netbox"

  Database = var.Netbox.Database

  Admin = var.Netbox.Admin

  Token = var.Netbox.Token
}

#
# DHCP
#

module "DHCP" {
  source = "./Jobs/DHCP"

  Database = var.DHCP.Database
}

#
# DNS
#

module "DNS" {
  source = "./Jobs/DNS"

  Netbox = {
    Hostname = "netbox-http-cont.service.kjdev"
    Port = 8080

    Token = var.Netbox.Token
  }
}

#
# Mattermsot
#
module "Mattermost" {
  source = "./Jobs/Mattermost"

  Database = var.Mattermost.Database
}

#
# Tinkerbell
#

module "Tinkerbell" {
  source = "./Jobs/Tinkerbell"

  Database = var.Tinkerbell.Database

  TLS = var.Tinkerbell.TLS
}

#
# Machine Static
#
module "MachineStatic" {
  source = "./Jobs/MachineStatic"
}

#
# TrueCommand
#

module "TrueCommand" {
  source = "./Jobs/TrueCommand"
}

#
# NextCloud
#

module "NextCloud" {
  source = "./Jobs/NextCloud"

  Database = var.NextCloud.Database

  S3 = var.NextCloud.S3

  Credentials = var.NextCloud.Credentials
}

#
# OpenProject
#
# module "OpenProject" {
#   source = "./Jobs/OpenProject"

#   Database = var.NextCloud.Database

#   S3 = var.NextCloud.S3
# }


#
# eJabberD
#
module "eJabberD" {
  source = "./Jobs/eJabberd"

  Database = var.eJabberD.Database

  OpenID = var.eJabberD.OpenID

  TLS = var.eJabberD.TLS
}

#
# HomeAssistant
#
module "HomeAssistant" {
  source = "./Jobs/HomeAssistant"

  Database = var.HomeAssistant.Database

  OpenID = var.HomeAssistant.OpenID

  TLS = var.HomeAssistant.TLS

  MQTT = var.HomeAssistant.MQTT

  Secrets = var.HomeAssistant.Secrets
}