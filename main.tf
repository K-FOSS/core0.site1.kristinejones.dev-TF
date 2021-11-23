terraform {
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

#
# Hashicorp Vault
#

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

#
# Hashicorp Consul
#

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

#
# Grafana Cortex
#

module "CortexBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

module "AlertManagerBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# Grafana Loki
#

module "LokiBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# Grafana Tempo
#

module "TempoBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# NextCloud
# 
module "NextCloud" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# OpenProject
#

module "OpenProjectBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

module "OpenProjectNewBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# Consul Backups
#

module "ConsulBackupsBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# Development
#

#
# GitLab
#

#
# TODO
#

module "GitLabRepoBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# GitLab Artifacts Bucket
#

module "GitLabArtifactsBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# GitLab External Diffs Buckets
#

module "GitLabExternalDiffsBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# GitLab LFS Bucket
#

module "GitLabLFSBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# GitLab Uplaods Bucket
#

module "GitLabUploadsBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# GitLab Packages Bucket
#

module "GitLabPackagesBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# Gitlab Dependency Proxy Bucket
#

module "GitLabDependencyProxyBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# GitLab Terraform State Bucket
#

module "GitLabTerraformStateBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}

#
# GitLab Pages Bucket
#

module "GitLabPagesBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
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
    Hostname = "node3.core0.site1.kristianjones.dev"
    Port = 9000
  }

  Credentials = module.Vault.Minio
}


#
# Databases
#


#
# Grafana Database 
#

module "GrafanaDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Authentik Database
#
module "AuthentikDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# CoTurn
#

module "CoTurnDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Netbox
#
module "NetboxDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# DHCP Database
#
module "DHCPDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

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
# HomeAssistant
#
module "HomeAssistantDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# PowerDNS Authoritative DNS Server
#
module "PowerDNSDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Observability Stacks
#

#
# Grafana Cortex Config Database
#

module "CortexConfigDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Grafana Loki Database
#

module "GrafanaLokiConfigDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

#
# Development
#

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

#
# Registry
#

module "HarborRegistryDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}

 
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
      Hostname = "172.16.20.21"
      Port = 36009

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
  # AAA
  #

  #
  # Authentik
  #

  Authentik = {
    Database = module.AuthentikDatabase.Database

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

    Secrets = module.Pomerium.Secrets


    TLS = {
      CA = module.Vault.Pomerium.TLS.CA

      Redis = module.Vault.Pomerium.TLS.Redis

      Grafana = {
        CA = module.Vault.Grafana.TLS.CA
      }

      HomeAssistant = {
        CA = module.Vault.HomeAssistant.TLS.CA
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
  }

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
  }


  #
  # Mattermost
  #
  Mattermost = {
    Database = module.Mattermost.Database
  }
  
  #
  # Tinkerbell
  #
  Tinkerbell = {
    Database = module.TinkerbellDatabase.Database

    TLS = module.Vault.Tinkerbell

    Boots = {
      DockerHub = module.Vault.DockerHub
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
  # OpenProject
  #
  OpenProject = {
    Database = module.OpenProjectDatabase.Database

    S3 = module.OpenProjectNewBucket

    SMTP = module.Vault.SMTP
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
  # Consul Backups
  #
  ConsulBackups = {
    Consul = module.Consul.Backups

    S3 = module.ConsulBackupsBucket
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
    Database = module.GitLabNewDatabase.Database

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
      S3 = module.HarborRegistryBucket

      Database = module.HarborRegistryDatabase.Database

      TLS = module.Vault.Registry.Harbor.TLS
    }
  }
} 