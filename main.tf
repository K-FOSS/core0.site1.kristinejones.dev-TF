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
    Hostname = "core0.site1.kristianjones.dev"
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
    Hostname = "core0.site1.kristianjones.dev"
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
    Hostname = "core0.site1.kristianjones.dev"
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
    Hostname = "core0.site1.kristianjones.dev"
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
    Hostname = "core0.site1.kristianjones.dev"
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
    Hostname = "core0.site1.kristianjones.dev"
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

module "GitLabRepoBucket" {
  source = "./Minio"

  Connection = {
    Hostname = "core0.site1.kristianjones.dev"
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
# GitLab
#

module "GitLabDatabase" {
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

  TLS = {
    Proxy = module.Vault.PomeriumTLS.Proxy

    DataBroker = module.Vault.PomeriumTLS.DataBroker

    Authenticate = module.Vault.PomeriumTLS.Authenticate

    Authorize = module.Vault.PomeriumTLS.Authorize
  }
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
      Hostname = "172.31.241.2"
      Port = 36009

      Username = module.Vault.BitwardenDB.data["username"]
      Password = module.Vault.BitwardenDB.data["password"]

      Database = "bitwarden"
    }
  }

  #
  # Caddy Web Ingress
  #

  Ingress = {
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
    OpenID = module.Vault.Pomerium

    Secrets = module.Pomerium.Secrets

    Authenticate = {
      TLS = module.Vault.PomeriumTLS.Authenticate
    }

    Authorize = {
      TLS = module.Vault.PomeriumTLS.Authorize
    }

    DataBroker = {
      TLS = module.Vault.PomeriumTLS.DataBroker
    }

    Proxy = {
      TLS = module.Vault.PomeriumTLS.Proxy
    }

    TLS = {
      CA = module.Vault.PomeriumTLS.CA

      Redis = module.Vault.PomeriumTLS.Redis

      Grafana = {
        CA = module.Vault.Grafana.TLS.CA
      }

      HomeAssistant = {
        CA = module.Vault.HomeAssistant.TLS.CA
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
    }

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

      Targets = module.Tempo.Targets

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
  # OpenProject = {
  #   Database = module.OpenProjectDatabase.Database

  #   S3 = module.OpenProjectBucket
  # }

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
  # Development
  #

  GitLab = {
    Database = module.GitLabDatabase.Database

    S3 = {
      RepoBucket = module.GitLabRepoBucket
    }
  }
} 