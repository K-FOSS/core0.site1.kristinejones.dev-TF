terraform {
  backend "http" {}

  required_providers {
    #
    # Hashicorp Consul
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/consul/latest/docs
    #
    consul = {
      source = "hashicorp/consul"
      version = "2.13.0"
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

#########################
#      Core Services    #
#########################

###################
# Hashicorp Vault #
###################

module "Vault" {
  source = "./Vault"

  Pomerium = {
    VaultPath = module.Consul.Pomerium.OIDVaultPath
  }

  eJabberD = module.Consul.eJabberD

  Tinkerbell = {
    Admin = module.Nomad.Tinkerbell.Admin
  }
}

#################### 
# Hashicorp Consul #
####################

module "Consul" {
  source = "./Consul"

  Patroni = {
    Prefix = "patroninew"
    ServiceName = "patroninew"
  }

  Cortex = {
    Prefix = "cortex"
  }

  Loki = {
    Prefix = "loki"
  }

  Tempo = {
    Prefix = "tempo"
  }

  HomeAssistant = {
    TLS = {
      CA = module.Vault.HomeAssistant.TLS.CA

      Cert = module.Vault.HomeAssistant.TLS.Server.Cert
      Key = module.Vault.HomeAssistant.TLS.Server.Key
    }

    Connection = {
      Hostname = "172.31.241.2"
      Port = 36006
    }
  }
}

#
# Minio S3 Storage Modules
#

####################
#      Buckets     #
####################

########
# AAA #
#######

#
# Authentik
#

module "AuthentikBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# Teleport Audit Storage
#
module "TeleportAuditBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

###########
# Backups #
###########

#
# Consul Backups
#

module "ConsulBackupsBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# PSQL
#

module "PSQLBackupsBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

###########
# Metrics #
###########

#
# Grafana Cortex
#

module "CortexBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

module "AlertManagerBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

########
# Logs #
########

#
# Grafana Loki
#

module "LokiBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

###########
# Tracing #
###########

#
# Grafana Tempo
#

module "TempoBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

############
# Business #
############

#
# NextCloud
#

module "NextCloud" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# OpenProject
#

module "OpenProjectBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

module "OpenProjectNewBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# Outline
#

module "OutlineBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# Zammad
#



##################
# Communications #
##################

module "MattermostBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}



###############
# Development #
###############

#
# GitLab
#

#
# TODO
#

module "GitLabRepoBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# GitLab Artifacts Bucket
#

module "GitLabArtifactsBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# GitLab External Diffs Buckets
#

module "GitLabExternalDiffsBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# GitLab LFS Bucket
#

module "GitLabLFSBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# GitLab Uplaods Bucket
#

module "GitLabUploadsBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# GitLab Packages Bucket
#

module "GitLabPackagesBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# Gitlab Dependency Proxy Bucket
#

module "GitLabDependencyProxyBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# GitLab Terraform State Bucket
#

module "GitLabTerraformStateBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# GitLab Pages Bucket
#

module "GitLabPagesBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# GitLab Pages
#


#
# Harbor Registry Bucket
#
module "HarborRegistryBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

module "HarborChartsBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# OpenVSX
# 

module "OpenVSXBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

######################
# Documentation/Docs #
######################

#############
# Education #
#############

#
# Moodle
#

module "MoodleRepositoryBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

##########
# Search #
##########

#
# OpenSearch
#

module "OpenSearchRepoBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

#
# SourceGraph
#


############
# Security #
############

#
# IntelOwl
#

#
# MISP
#

#
# ThreatMapper
#

module "ThreatMapperBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "http.minio.web.service.kjdev"
    Port = 9080
  }

  Credentials = module.Vault.Minio
}

###########################
#         Databases       #
###########################


#
# Grafana Database 
#

module "GrafanaDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#######
# AAA #
#######

#
# Authentik Database
#

module "AuthentikDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Gravational Teleport
#

module "TeleportDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# HeadScale
#

module "HeadScaleDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# NetMaker
#

module "NetMakerDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

############
# Business #
############

#
# NextCloud
#
module "NextCloudDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}


module "NextCloudNewDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# OpenProject
#
module "OpenProjectDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Task System
#

module "VikunjaDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Notes
#

module "OutlineDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Feeds/ReadFlow
#

module "ReadFlowDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}


#
# Ticket System
#

#
# Zammad
#

module "ZammadDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}


##################
# Communications #
##################

#
# CoTurn
#

module "CoTurnDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

############
# Database #
############

#
# MongoDB
# 

module "FerretDBDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

############# 
# Inventory #
#############

#
# Netbox
#
module "NetboxDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Devices
#

#
# MeshCentral
#

module "MeshCentralDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

########### 
# Network #
###########

#
# DHCP Database
#
module "DHCPDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# NS
#

#
# PowerDNS Authoritative DNS Server
#

module "PowerDNSDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# NS Admin
#

module "PowerDNSAdminDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# ENMS Database
#


#
# TODO: ENMS
#

module "ENMSDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}


#
# Tinkerbell
#

module "TinkerbellDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Tinkerbell
#
module "Tinkerbell" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Monitoring
#

#
# OpenNMS
#

module "OpenNMSDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}


##################
# Communications #
##################

#
# Mattermost
#
module "Mattermost" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# eJabberD
#
module "eJabberDDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

# 
# Smart Home
#


#
# HomeAssistant
#
module "HomeAssistantDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

###############
# Development #
###############

#
# Gitea
#

module "GiteaDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# GitLab
#

module "GitLabDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

module "GitLabNewDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

module "GitLabPraefectDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

######################
# Documentation/Docs #
######################


######################
#      Education     #
######################

#
# Moodle
#

module "MoodleDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}


#
# Observability Stacks
#

###########
# Metrics #
###########

#
# Grafana Cortex Config Database
#

module "CortexConfigDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

########
# Misc #
########

#
# Ivatar
#

module "IvatarDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

########
# Logs #
########

#
# Grafana Loki Database
#

module "GrafanaLokiConfigDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

############
# Registry #
############

module "HarborRegistryDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

##########
# Search #
##########

#
# SourceGraph
#

module "SourceGraphDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

############
# Security #
############

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

module "ThreatMapperDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Zeek
#

 
#
# Hashicorp Nomad
#

#
# Networking Stacks
#

#
# Tinkerbell
#
# TODO: Stuff & Things
#

#
# Ingress Stacks
#

module "Pomerium" {
  source = "./Pomerium"
}

#
# Grafana Observibility Stacks
#


#
# Grafana Cortex Services
#
module "Cortex" {
  source = "./Cortex"
}

#
# Grafana Loki Services
#
module "Loki" {
  source = "./Loki"
}

#
# Grafana Tempo Services
#
module "Tempo" {
  source = "./Tempo"
}

#
# Nomad Scheduler and Tasker
#

module "Nomad" {
  source = "./Nomad"

  #
  # AAA
  # 
  # TODO: Move all AAA
  #

  AAA = {
    Authentik = {
      Domain = "mylogin.space"

      #
      # TODO: move Users to ERPNext & Terraform
      #

      Backups = {
        S3 = module.AuthentikBucket
      }
    }

    Teleport = {
      OpenID = module.Vault.AAA.Teleport.OpenID

      S3 = module.TeleportAuditBucket

      TLS = module.Vault.AAA.Teleport.TLS
    }

    #
    # TODO: Move Pomerium Here
    #
  }

  #
  # Backups
  #
  Backups = {
    Consul = {
      Consul = module.Consul.Backups

      S3 = module.ConsulBackupsBucket
    }

    PSQL = {
      S3 = module.PSQLBackupsBucket

      Database = {
        Hostname = module.Vault.Database.Hostname
        Port = module.Vault.Database.Port

        Username = module.Vault.Database.Username
        Password = module.Vault.Database.Password

        Database = "postgres"
      }
    }
  }

  #
  # GitHub Token
  #
  GitHub = {
    Token = module.Vault.GitHub.Token
  }

  #
  # Bitwarden
  #

  Bitwarden = {
    Database = {
      Hostname = module.Vault.Database.Hostname
      Port = module.Vault.Database.Port

      Username = module.Vault.Bitwarden.Database.Username
      Password = module.Vault.Bitwarden.Database.Password

      Database = "bitwarden"
    }

    TLS = module.Vault.Bitwarden.TLS

    SMTP = module.Vault.SMTP
  }

  #
  # Caddy Web Ingress
  #

  Web = {
    Cloudflare = {
      Token = module.Vault.Cloudflare.data["Token"]
    }

    Consul = {
      Token = module.Vault.Caddy.data["CONSUL_HTTP_TOKEN"]
      EncryptionKey = module.Vault.Caddy.data["CADDY_CLUSTERING_CONSUL_AESKEY"]
    }
  }

  #
  # Grafana
  #

  Grafana = {
    Database = module.GrafanaDatabase.Database

    TLS = module.Vault.Grafana.TLS
  }

  #
  # Authentik
  #

  Authentik = {
    Database = module.AuthentikDatabase.Database

    LDAP = module.Vault.AAA.Authentik.LDAP

    SMTP = module.Vault.SMTP
  }

  #
  # Patroni
  #
  Patroni = {
    Consul = module.Consul.Patroni
  }

  #
  # Pomerium
  #
  Pomerium = {
    OpenID = module.Vault.Pomerium.OpenID

    Secrets = {
      CookieSecret = module.Pomerium.Secrets.CookieSecret
      SharedSecret = module.Pomerium.Secrets.SharedSecret

      SigningKey = module.Vault.Pomerium.Secrets.SigningKey
    }


    TLS = {
      CA = module.Vault.Pomerium.TLS.CA

      Redis = module.Vault.Pomerium.TLS.Redis

      Grafana = {
        CA = module.Vault.Grafana.TLS.CA
      }

      HomeAssistant = {
        CA = module.Vault.HomeAssistant.TLS.CA
      }

      GitLab = {
        CA = module.Vault.GitLab.TLS.WorkHorse.CA
      }

      Authenticate = {
        Metrics = {
          Server = module.Vault.Pomerium.TLS.Authenticate.Metrics.Server

          Client = {
            CA = ""
          }
        }

        Server = module.Vault.Pomerium.TLS.Authenticate.Server
      }

      Authorize = {
        Metrics = {
          Server = module.Vault.Pomerium.TLS.Authorize.Metrics.Server

          Client = {
            CA = ""
          }
        }

        Server = module.Vault.Pomerium.TLS.Authorize.Server
      }

      DataBroker = {
        Metrics = {
          Server = module.Vault.Pomerium.TLS.DataBroker.Metrics.Server

          Client = {
            CA = ""
          }
        }

        Server = module.Vault.Pomerium.TLS.DataBroker.Server
      }

      Proxy = {
        Metrics = {
          Server = module.Vault.Pomerium.TLS.Proxy.Metrics.Server

          Client = {
            CA = ""
          }
        }

        Server = module.Vault.Pomerium.TLS.Proxy.Server
      }
    }
  }

  #
  # CoTurn
  #
  CoTurn = {
    CoTurn = {
      Realm = "kristianjones.dev"
    }

    Database = module.CoTurnDatabase.Database
  }

  Metrics = {
    Cortex = {
      Consul = module.Consul.Cortex

      Database = module.CortexConfigDatabase.Database

      Targets = module.Cortex.Targets

      S3 = module.CortexBucket

      AlertManagerBucket = module.AlertManagerBucket
    }

    SMTP = module.Vault.SMTP

    Prometheus = {
      Grafana = {
        CA = module.Vault.Grafana.TLS.CA
      }

      CoreVault = {
        Token = module.Vault.CoreVault.Prometheus.Token
      }

      Vault = {
        Token = module.Vault.Vault.Prometheus.Token
      }

      Minio = {
        AccessToken = module.Vault.Minio.AccessToken
      }

      HomeAssistant = {
        CA = module.Vault.HomeAssistant.TLS.CA

        AccessToken = module.Vault.HomeAssistant.AccessToken
      }
    }

    MikroTik = {
      Devices = tomap({
        Home1 = module.Vault.MikroTik.Home1
      })
    }

    iDRAC = {
      Username = module.Vault.iDRAC.Username
      Password = module.Vault.iDRAC.Password

      Devices = tomap({
        VMH1 = {
          IPAddress = "172.16.20.61"
        }
        VMH2 = {
          IPAddress = "172.16.20.62"
        }
        NAS1 = {
          IPAddress = "172.16.20.64"
        }
      })
    }

    MSTeams = {
      Webhook = module.Vault.MSTeams.Webhook
    }
  }

  #
  # Misc
  #

  Misc = {
    Ivatar = {
      Database = module.IvatarDatabase.Database

      OpenID = module.Vault.Misc.Ivatar.OpenID
    }
  }

  #
  # Syslogs
  #
  # Loki, Vector
  #
  Logs = {
    Loki = {
      Consul = module.Consul.Loki

      Database = module.GrafanaLokiConfigDatabase.Database

      Targets = module.Loki.Targets

      S3 = module.LokiBucket
    }
  }

  #
  # Tracing
  #
  # Grafana Tempo, etc
  #
  Tracing = {
    Tempo = {
      Consul = module.Consul.Tempo

      S3 = module.TempoBucket
    }
  }

  #
  # CSI NFS/iSCSI Storage
  #
  Storage = {
    NAS = {
      Hostname = "172.16.51.21"

      Admin = {
        Hostname = "172.16.20.21"
      }

      Password = module.Vault.NAS.Password
    }

    Minio = module.Vault.Minio
  }


  #
  # Inventory
  #

  Inventory = {
    #
    # Netbox DCIM
    #
    Netbox = {
      Database = module.NetboxDatabase.Database

      Admin = {
        Username = "kjones"
        Email = "k@kristianjones.dev"
      }

      Token = module.Vault.Netbox.Token
    }


    MeshCentral = {
      Database = module.MeshCentralDatabase.Database
    }
  }

  #
  # Networking
  #
  Network = {
    Monitoring = {
      OpenNMS = {
        Database = module.OpenNMSDatabase.Database
      }
    }
  }


  #
  # ISC Kea DHCP
  #

  DHCP = {
    Database = module.DHCPDatabase.Database

    TLS = module.Vault.DHCP.TLS
  }

  #
  # CoreDNS DNS
  #
  DNS = {
    Consul = module.Consul.DNS
  }

  #
  # Configuration for Authoritative NS Servers
  #
  NS = {
    PowerDNS = {
      Database = module.PowerDNSDatabase.Database
    }

    PowerDNSAdmin = {
      Database = module.PowerDNSAdminDatabase.Database
    }
  }

  #
  # ENMS
  #

  ENMS = {
    Database = module.ENMSDatabase.Database

    Repo = module.Vault.ENMS.Repo
  }

  Communications = {
    #
    # Mattermost
    #
    Mattermost = {
      Database = module.Mattermost.Database

      GitLab = module.Vault.Communications.Mattermost.GitLab

      S3 = module.MattermostBucket
    }
  }

  #
  # Databases
  #
  Databases = {
    MongoDB = {
      Database = module.FerretDBDatabase.Database
    }
  }

  #
  # Servers
  #
  Servers = {
    Rancher = {
      OpenID = module.Vault.Servers.Rancher.OpenID

      LDAP = module.Vault.Servers.Rancher.LDAP
    }

    HashUI = {
      OpenID = module.Vault.Servers.HashUI.OpenID

      LDAP = module.Vault.Servers.HashUI.LDAP
    }

    #
    # Tinkerbell
    #
    Tinkerbell = {
      Database = module.TinkerbellDatabase.Database

      TLS = module.Vault.Tinkerbell

      Boots = {
        Registry = module.Vault.Registry.Credentials
      }
    }
  }

  #
  # Business Apps
  #

  #
  # NextCloud
  #
  NextCloud = {
    Database = module.NextCloudNewDatabase.Database

    S3 = module.NextCloud

    Credentials = module.Vault.NextCloud
  }



  #
  # Automation
  #

  #
  # Machine to Machine (M2M)
  #
  eJabberD = {
    #
    # TODO: OpenID OAuth/Users/LDAP to Authentik
    #
    OpenID = module.Vault.eJabberD.OpenID

    LDAP = module.Vault.eJabberD.LDAP

    Database = module.eJabberDDatabase.Database

    TLS = module.Vault.eJabberD.TLS
  }

  #
  # HomeAssistant Home Automation
  #
  HomeAssistant = {
    OpenID = module.Vault.HomeAssistant.OpenID

    Database = module.HomeAssistantDatabase.Database

    MQTT = module.Vault.HomeAssistant.MQTT

    TLS = module.Vault.HomeAssistant.TLS

    Secrets = module.Vault.HomeAssistant.Secrets
  }

  #
  # Cache
  #

  Cache = {
    Pomerium = {
      RedisCache = {
        TLS = module.Vault.Pomerium.TLS.Redis
      }
    }
  }

  #
  # Development
  #

  GitLab = {
    Database = {
      Core = module.GitLabNewDatabase.Database

      Praefect = module.GitLabPraefectDatabase.Database
    }

    LDAP = {
      Credentials = module.Vault.GitLab.LDAP
    }

    TLS = module.Vault.GitLab.TLS

    Secrets = module.Vault.GitLab.Secrets

    S3 = {
      ArtifactsBucket = module.GitLabArtifactsBucket

      ExternalDiffsBucket = module.GitLabExternalDiffsBucket

      RepoBucket = module.GitLabRepoBucket

      LFSBucket = module.GitLabLFSBucket

      UploadsBucket = module.GitLabUploadsBucket

      PackagesBucket = module.GitLabPackagesBucket

      DependencyProxyBucket = module.GitLabDependencyProxyBucket

      TerraformStateBucket = module.GitLabTerraformStateBucket

      PagesBucket = module.GitLabPagesBucket
    }

    OpenID = module.Vault.GitLab.OpenID

    SMTP = module.Vault.SMTP
  }

  #############
  # Education #
  #############

  Education = {
    Moodle = {
      Database = module.MoodleDatabase.Database

      OpenID = {
        ClientID = ""
        ClientSecret = ""
      }

      S3 = {
        Repository = module.MoodleRepositoryBucket
      }

      TLS = module.Vault.Education.Moodle.TLS
    }
  }

  #
  # Ingress
  #
  Ingress = {
    GoBetween = {
      Consul = module.Consul.GoBetween
    }
  }

  #
  # Registry
  #
  Registry = {
    #
    # Harbor Registry
    #
    Harbor = {
      S3 = {
        Images = module.HarborRegistryBucket
        Charts = module.HarborChartsBucket
      }

      Database = module.HarborRegistryDatabase.Database

      TLS = module.Vault.Registry.Harbor.TLS
    }
  }

  #
  # Search
  #
  Search = {
    OpenSearch = {
      OpenID = {
        ClientID = ""
        ClientSecret = ""
      }

      TLS = module.Vault.Search.OpenSearch.TLS

      S3 = {
        CoreRepo = module.OpenSearchRepoBucket
      }
    }

    SourceGraph = {
      Database = module.SourceGraphDatabase.Database
    }
  }

  #
  # Security
  #

  Security = {
    ThreatMapper = {
      Database = module.ThreatMapperDatabase.Database
    }
  }

  #
  # Business
  #
  Business = {
    Vikunja = {
      Database = module.VikunjaDatabase.Database

      OpenID = module.Vault.Business.Vikunja.OpenID

      SMTP = module.Vault.SMTP
    }

    Outline = {
      Database = module.OutlineDatabase.Database

      S3 = module.OutlineBucket

      OpenID = module.Vault.Business.Outline.OpenID

      SMTP = module.Vault.SMTP
    }

    ReadFlow = {
      Database = module.ReadFlowDatabase.Database
    }

    Zammad = {
      Database = module.ZammadDatabase.Database

      SMTP = module.Vault.SMTP
    }
  }

  #
  # OpenProject
  #
  OpenProject = {
    Database = module.OpenProjectDatabase.Database

    OpenID = module.Vault.OpenProject.OpenID

    S3 = module.OpenProjectNewBucket

    SMTP = module.Vault.SMTP
  }
} 
