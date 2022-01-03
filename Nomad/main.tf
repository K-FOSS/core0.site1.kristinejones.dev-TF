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

#######
# AAA #
#######

#########################################
#             Authentik                 #
#                                       #
# Website: https://goauthentik.io/      #
# Docs: goauthentik.io/docs/            #
# Purpose: Identity Provider            #
#########################################

resource "random_string" "AuthentikSecretKey" {
  length = 10
  special = false
}

module "Authentik" {
  source = "./Jobs/AAA/Authentik"

  Domain = var.AAA.Authentik.Domain

  S3 = var.AAA.Authentik.Backups.S3

  Database = var.Authentik.Database

  Secrets = {
    SecretKey = random_string.AuthentikSecretKey.result
  }

  LDAP = var.Authentik.LDAP

  SMTP = var.Authentik.SMTP
}

#############################################
#          Hashicorp Boundary               # 
#                                           #
# Website: https://www.boundaryproject.io/  #
#                                           #
#############################################

#########################################
#                Teleport               #
#                                       #
# Website: https://goteleport.com/      #
# Docs: https://goteleport.com/docs/    #
#                                       #
#########################################

module "Teleport" {
  source = "./Jobs/AAA/Teleport"

  OpenID = var.AAA.Teleport.OpenID

  S3 = var.AAA.Teleport.S3

  TLS = var.AAA.Teleport.TLS
}


####################################
#            Pomerium              #
####################################

module "Pomerium" {
  source = "./Jobs/AAA/Pomerium"

  OpenID = var.Pomerium.OpenID

  TLS = var.Pomerium.TLS

  Secrets = var.Pomerium.Secrets
}

##############################
#         Wiretrustee        #
#                            #
#                            #
##############################


##############################
#          HeadScale         #
#                            #
#                            #
#                            #
##############################




###################
#                 #
#                 #
#     Backups     #
#                 #
#                 #
###################

###########
# Backups #
###########

module "ConsulBackups" {
  source = "./Jobs/Backups/ConsulBackups"

  Consul = var.Backups.Consul.Consul

  S3 = var.Backups.Consul.S3
}

#
# PSQL Backups
#
module "PSQLBackups" {
  source = "./Jobs/Backups/PSQL"

  S3 = var.Backups.PSQL.S3

  Database = var.Backups.PSQL.Database
}



##################################
#            Business            #
##################################

###############################################
#               OpenProject                   #
#                                             #
# Website: https://www.openproject.org/       #
# Docs: https://www.openproject.org/docs/     #
#                                             #
################################################


module "OpenProject" {
  source = "./Jobs/Business/OpenProject"

  Database = var.OpenProject.Database

  OpenID = var.OpenProject.OpenID

  S3 = var.OpenProject.S3

  SMTP = var.OpenProject.SMTP

  Admin = {
    Username = "kjones"
    Email = "k@kristianjones.dev"
  }
}


#############################################
#                Zammad                     #
#                                           #
# Website: https://zammad.org/              #
# Docs: https://zammad.org/documentation    #
# Helm Chart: TODO                          #
#                                           #
#############################################

module "Zammad" {
  source = "./Jobs/Business/Zammad"

  Database = var.Business.Zammad.Database

  SMTP = var.Business.Zammad.SMTP
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
# Task System
#

module "Vikunja" {
  source = "./Jobs/Business/Vikunja"

  Database = var.Business.Vikunja.Database

  OpenID = var.Business.Vikunja.OpenID

  SMTP = var.Business.Vikunja.SMTP
}



#
# Notes
#

#
# Outline
#

module "Outline" {
  source = "./Jobs/Business/Outline"

  Database = var.Business.Outline.Database

  OpenID = var.Business.Outline.OpenID

  S3 = var.Business.Outline.S3

  SMTP = var.Business.Outline.SMTP
}

#
# ReadFlow
#

module "ReadFlow" {
  source = "./Jobs/Business/ReadFlow"

  Database = var.Business.ReadFlow.Database
}

#####################
#        Caches     #
#####################

module "Cache" {
  source = "./Jobs/Cache"

  Pomerium = var.Cache.Pomerium

  eJabberD = {
    Redis = module.eJabberD.Redis
  }

  AAA = {
    Teleport = {
      CA = var.AAA.Teleport.TLS.CA

      ETCD = var.AAA.Teleport.TLS.ETCD
    }
  }

  IPAM = {
    Netbox = {
      Redis = module.NetboxJob.Redis
    }
  }
}


#################################
#          Communications       #
#################################
##

#
# MatterBridge
#

module "MatterBridge" {
  source = "./Jobs/Communications/MatterBridge"
}

#
# Mattermost
#

module "Mattermost" {
  source = "./Jobs/Communications/Mattermost"

  Database = var.Communications.Mattermost.Database

  S3 = var.Communications.Mattermost.S3

  GitLab = var.Communications.Mattermost.GitLab

  SMTP = var.OpenProject.SMTP
}

##############################
#           Databases        #
##############################

#
# MongoDB
#
module "MongoDB" {
  source = "./Jobs/Databases/MongoDB"

  Database = var.Databases.MongoDB.Database
}


########
# Mesh #
########

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
# Bitwarden
#

module "Bitwarden" {
  source = "./Jobs/Bitwarden"

  Database = var.Bitwarden.Database

  TLS = var.Bitwarden.TLS

  SMTP = var.Bitwarden.SMTP
}

##############
# Dashboards #
##############

#
# Grafana
#

module "Grafana" {
  source = "./Jobs/Grafana"

  Database = var.Grafana.Database

  TLS = var.Grafana.TLS
}



#
# Caddy Web Ingress
#

module "Web" {
  source = "./Jobs/Web"

  Consul = var.Web.Consul

  CloudFlare = var.Web.Cloudflare

  AAA = {
    Teleport = {
      CA = var.AAA.Teleport.TLS.CA
    }
  }

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

#
# Inventory
#


#
# DCIM
#

module "NetboxJob" {
  source = "./Jobs/Inventory/DCIM/Netbox"

  Database = var.Inventory.Netbox.Database

  Admin = var.Inventory.Netbox.Admin

  Token = var.Inventory.Netbox.Token
}

#
# Mesh Central Mobility Management
#

module "MeshCentral" {
  source = "./Jobs/Inventory/Machines"

  Database = var.Inventory.MeshCentral.Database
}

########################################
#               Network                #
########################################



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
    Hostname = "http.netbox.service.kjdev"
    Port = 8080

    Token = var.Inventory.Netbox.Token
  }

  Consul = var.DNS.Consul

  PowerDNS = var.NS.PowerDNS
}

#
# OpenNMS
#
module "OpenNMS" {
  source = "./Jobs/Network/Monitoring/OpenNMS"

  Database = var.Network.Monitoring.OpenNMS.Database
}

#
# Oxidized
#

# module "Oxidized" {
#   source = "./Jobs/Network/Monitoring/Oxidized"

#   Git = var.Network.Monitoring.Oxidized.Git
# }

#
# LookingGLass
#

module "LookingGlass" {
  source = "./Jobs/Network/LookingGlass"
}
 
#
# NS
#

module "NS" {
  source = "./Jobs/Network/NS"

  PowerDNS = var.NS.PowerDNS

  PowerDNSAdmin = var.NS.PowerDNSAdmin
}

#
# ENMS
#

module "ENMS" {
  source = "./Jobs/Network/ENMS"

  Database = var.ENMS.Database

  Repo = var.ENMS.Repo
}

#
# Office
#

module "Office" {
  source = "./Jobs/Office"
}


#
# NATPunch
#
module "NATPunch" {
  source = "./Jobs/Network/NATPunch"

  CoTurn = {
    Realm = "kristianjones.dev"

    Database = var.CoTurn.Database
  }
}



#################################
#           Servers             #
#################################

#
# Hash-UI
#
module "HashUI" {
  source = "./Jobs/Servers/Hash-UI"

  OpenID = var.Servers.HashUI.OpenID

  LDAP = var.Servers.HashUI.LDAP
}

#
# Rancher
#

module "Rancher" {
  source = "./Jobs/Servers/Rancher"

  OpenID = var.Servers.Rancher.OpenID

  LDAP = var.Servers.Rancher.LDAP
}

#
# Tinkerbell
#

module "Tinkerbell" {
  source = "./Jobs/Servers/Tinkerbell"

  Database = var.Servers.Tinkerbell.Database

  TLS = var.Servers.Tinkerbell.TLS

  Boots = var.Servers.Tinkerbell.Boots
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
# Minio
#

module "Minio" {
  source = "./Jobs/Storage/Minio"

  Minio = var.Storage.Minio
}




#
# eJabberD
#
module "eJabberD" {
  source = "./Jobs/eJabberd"

  Database = var.eJabberD.Database

  LDAP = {
    Credentials = var.eJabberD.LDAP
  }

  OpenID = var.eJabberD.OpenID

  TLS = var.eJabberD.TLS
}

######################
#    HomeAssistant   #
######################

module "HomeAssistant" {
  source = "./Jobs/HomeAssistant"

  Database = var.HomeAssistant.Database

  OpenID = var.HomeAssistant.OpenID

  TLS = var.HomeAssistant.TLS

  MQTT = var.HomeAssistant.MQTT

  Secrets = var.HomeAssistant.Secrets
}





#
# Draw
#
module "Draw" {
  source = "./Jobs/Draw"
}

#########################
#      Development      #
#########################

#
# Gitea
#

# module "Gitea" {
#   source = "./Jobs/Development/Gitea"
# }

module "GitLab" {
  source = "./Jobs/Development/GitLab"
  
  Database = var.GitLab.Database

  LDAP = var.GitLab.LDAP

  Secrets = var.GitLab.Secrets

  TLS = var.GitLab.TLS

  S3 = var.GitLab.S3

  OpenID = var.GitLab.OpenID

  SMTP = var.GitLab.SMTP
}

####################################
#           Documentation/Docs     #
####################################


####################################
#           Education              #
####################################

###################################
#           Moodle                #
#                                 #
# Website: https://moodle.org/    #
#                                 #
###################################

# module "Moodle" {
#   source = "./Jobs/Education/Moodle"
# }




#######################
#        Ingress      #
#######################

module "Ingress" {
  source = "./Jobs/Ingress"

  GoBetween = var.Ingress.GoBetween
}

############################
#        Registry          #
############################

module "Registry" {
  source = "./Jobs/Registry"

  Harbor = var.Registry.Harbor
}

#########################
#         Search        #
#########################

module "Search" {
  source = "./Jobs/Search"

  OpenSearch = var.Search.OpenSearch
}

#
# Security
#

#
# Argus
#

#
# IntelOwl
#

#
# IVRE
#

#
# MISP
#

#
# nProbe
#

#
# ThreatMapper
#

module "ThreatMapper" {
  source = "./Jobs/Security/ThreatMapper"

  Database = var.Security.ThreatMapper.Database

  TLS = var.Security.ThreatMapper.TLS
}

#
# Zeek
#

#
# Misc
#

module "Misc" {
  source = "./Jobs/Misc"

  Ivatar = var.Misc.Ivatar

  ShareX = var.Misc.ShareX
}


#
# N8N
#

# module "N8N" {
#   source = "./Jobs/Workflows/n8n"

#   Database = var.Workflows.N8N.Database
# }