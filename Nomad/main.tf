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

    #
    # GitHub Provider
    #
    # Used to fetch the latest PSQL file
    #
    # Docs: https://registry.terraform.io/providers/integrations/github/latest
    #
    github = {
      source = "integrations/github"
      version = "4.17.0"
    }
  }
}

#
# Nomad Provider
#
 
provider "nomad" {
  address = "http://nomadserver.service.dc1.kjdev:4646"
  region  = "global"
}

#
# GitHub
#

provider "github" {
  token = var.GitHub.Token

  #base_url = "http://github-cache-server.service.kjdev:8080/"
}

#
# Mesh
#

#
# Consul Core Server
#

#
# Consul DC1 Server
#

#
# Consul DC1 Cluster Agents
#

#
# Meshery
#

module "Meshery" {
  source = "./Jobs/Mesh/Meshery"
}

#
# CSI
#

# resource "nomad_job" "Storage" {
#   jobspec = templatefile("${path.module}/Jobs/Storage/Controller.hcl", {
#     CSI_CONFIG = templatefile("${path.module}/Jobs/Storage/Configs/CSI.yaml", var.Storage)
#   })
# }

# resource "nomad_job" "CSIStorage" {
#   jobspec = templatefile("${path.module}/Jobs/Storage/Node.hcl", {
#     CSI_CONFIG = templatefile("${path.module}/Jobs/Storage/Configs/CSI.yaml", var.Storage)
#   })
# }

#
# Pomerium
#

module "Pomerium" {
  source = "./Jobs/Pomerium"

  OpenID = var.Pomerium.OpenID

  TLS = var.Pomerium.TLS

  Secrets = var.Pomerium.Secrets
}


#
# Bitwarden
#
module "Bitwarden" {
  source = "./Jobs/Bitwarden"

  Database = var.Bitwarden.Database

  TLS = var.Bitwarden.TLS
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

module "Authentik" {
  source = "./Jobs/AAA/Authentik"

  Database = var.Authentik.Database

  Secrets = {
    SecretKey = random_string.AuthentikSecretKey.result
  }
}




#
# Caddy Web Ingress
#

module "Web" {
  source = "./Jobs/Web"

  Consul = var.Web.Consul

  CloudFlare = var.Web.Cloudflare

  Pomerium = {
    CA = var.Pomerium.TLS.CA
  }

  Harbor = {
    CA = var.Registry.Harbor.TLS.CA
  }

  HomeAssistant = {
    CA = var.HomeAssistant.TLS.CA
  }

  Bitwarden = {
    CA = var.Bitwarden.TLS.CA
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

# resource "nomad_volume" "Patroni" {
#   type                  = "csi"
#   plugin_id             = "truenas"
#   volume_id             = "patronidata-vol"
#   name                  = "patronidata-vol"
#   external_id           = "test-vol"

#   capability {
#     access_mode     = "multi-node-multi-writer"
#     attachment_mode = "file-system"
#   }

#   deregister_on_destroy = true

#   mount_options {
#     fs_type = "nfs"
#     mount_flags = ["nolock"]
#   }

#   context = {
#     node_attach_driver = "nfs"
#     provisioner_driver = "freenas-nfs"
#     server             = "172.16.51.21"
#     share              = "/mnt/Site1.NAS1.Pool1/CSI/vols/test-vol"
#   }
# }

module "Patroni" {
  source = "./Jobs/Patroni"

  Consul = var.Patroni.Consul
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

  Cortex = var.Metrics.Cortex

  Prometheus = var.Metrics.Prometheus

  MikroTik = var.Metrics.MikroTik

  iDRAC = var.Metrics.iDRAC

  MSTeams = var.Metrics.MSTeams

  SMTP = var.Metrics.SMTP
}

#
# Logs
# 
# Syslog, HTTP, Docker
#
# Vector/Syslog Stack
# Loki Stack
#

module "Logs" {
  source = "./Jobs/Logs"

  Loki = var.Logs.Loki
}

#
# Tracing
#
# Grafana Tempo
#

module "Tracing" {
  source = "./Jobs/Tracing"

  Tempo = var.Tracing.Tempo
}


module "NetboxJob" {
  source = "./Jobs/Inventory/DCIM/Netbox"

  Database = var.Netbox.Database

  Admin = var.Netbox.Admin

  Token = var.Netbox.Token
}

#
# DHCP
#

module "Kea" {
  source = "./Jobs/Network/DHCP"

  Database = var.DHCP.Database

  TLS = var.DHCP.TLS
}

#
# DNS
#

module "DNS" {
  source = "./Jobs/Network/DNS"

  Netbox = {
    Hostname = "netbox-http-cont.service.kjdev"
    Port = 8080

    Token = var.Netbox.Token
  }

  Consul = var.DNS.Consul
}

#
# NS
#

module "NS" {
  source = "./Jobs/NS"

  PowerDNS = var.NS.PowerDNS
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

  Boots = var.Tinkerbell.Boots
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
module "OpenProject" {
  source = "./Jobs/OpenProject"

  Database = var.NextCloud.Database

  S3 = var.NextCloud.S3
}


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

#
# Backups
# 
module "ConsulBackups" {
  source = "./Jobs/ConsulBackups"

  Consul = var.ConsulBackups.Consul

  S3 = var.ConsulBackups.S3
}

#
# Caches 
#

module "Cache" {
  source = "./Jobs/Cache"

  Pomerium = var.Cache.Pomerium
}

#
# Draw
#
module "Draw" {
  source = "./Jobs/Draw"
}

#
# Development
#

module "GitLab" {
  source = "./Jobs/GitLab"
  
  Database = var.GitLab.Database

  S3 = var.GitLab.S3
}

#
# Ingress
#
module "Ingress" {
  source = "./Jobs/Ingress"

  GoBetween = var.Ingress.GoBetween
}

#
# Registry
#

module "Registry" {
  source = "./Jobs/Registry"

  Harbor = var.Registry.Harbor
}