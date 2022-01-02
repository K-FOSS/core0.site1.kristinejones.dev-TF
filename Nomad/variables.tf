#
# GitHub
#
variable "GitHub" {
  type = object({
    Token = string
  })
}

##################
#      AAA       #
##################

variable "AAA" {
  type = object({
    Authentik = object({
      Domain = string

      Backups = object({
        S3 = object({
          Connection = object({
            Hostname = string
            Port = number

            Endpoint = string
          })

          Credentials = object({
            AccessKey = string
            SecretKey = string
          })


          Bucket = string
        })
      })
    })

    Teleport = object({
      OpenID = object({
        ClientID = string
        ClientSecret = string
      })

      S3 = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })


        Bucket = string
      })

      TLS = object({
        CA = string

        ETCD = object({
          CA = string

          Cert = string
          Key = string
        })

        Proxy = object({
          CA = string

          Cert = string
          Key = string
        })

        Auth = object({
          CA = string

          Cert = string
          Key = string
        })

        Tunnel = object({
          CA = string

          Cert = string
          Key = string
        })

        Kube = object({
          CA = string

          Cert = string
          Key = string
        })
      })
    })
  })
}

#####################
#     Bitwarden     #
#####################

variable "Bitwarden" {
  type = object({
    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    TLS = object({
      CA = string

      Server = object({
        Cert = string
        Key = string
      })
    })

    SMTP = object({
      Server = string
      Port = string

      Username = string
      Password = string
    })
  })
}

###################
#     Backups     #
###################

variable "Backups" {
  type = object({
    Consul = object({
      Consul = object({
        Hostname = string
        Port = number
    
        Token = string
      })

      S3 = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })

        Bucket = string
      })
    })

    PSQL = object({
      S3 = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })

        Bucket = string
      })

      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })
    })
  })
}

#####################
# Caddy Web Ingress #
#####################

variable "Web" {
  type = object({
    Consul = object({
      Token = string
      EncryptionKey = string
    })
    Cloudflare = object({
      Token = string
    })
  })
}

#
# Grafana
#

variable "Grafana" {
  type = object({
    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    TLS = object({
      CA = string

      Cert = string
      Key = string
    })
  })
}

#
# AAA
#

variable "Authentik" {
  type = object({
    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    LDAP = object({
      AuthentikHost = string
      AuthentikToken = string
    })

    SMTP = object({
      Server = string
      Port = string

      Username = string
      Password = string
    })
  })
}

#
# Patroni
#

variable "Patroni" {
  type = object({
    Consul = object({
      Hostname = string
      Port = number

      Token = string
    
      Prefix = string
      ServiceName = string
    })
  })

  description = "Patroni Configuration"
}

#
# Pomerium
#

variable "Pomerium" {
  type = object({
    OpenID = object({
      ClientID = string
      ClientSecret = string
    })

    TLS = object({
      CA = string

      Redis = object({
        Cert = string

        Key = string
      })

      Grafana = object({
        CA = string
      })

      HomeAssistant = object({
        CA = string
      })

      GitLab = object({
        CA = string
      })

      Authenticate = object({
        Metrics = object({
          Server = object({
            CA = string

            Cert = string
            Key = string
          })

          Client = object({
            CA = string
          })
        })

        Server = object({
          CA = string

          Cert = string
          Key = string
        })
      })

      Authorize = object({
        Metrics = object({
          Server = object({
            CA = string

            Cert = string
            Key = string
          })

          Client = object({
            CA = string
          })
        })

        Server = object({
          CA = string

          Cert = string
          Key = string
        })
      })

      DataBroker = object({
        Metrics = object({
          Server = object({
            CA = string

            Cert = string
            Key = string
          })

          Client = object({
            CA = string
          })
        })

        Server = object({
          CA = string

          Cert = string
          Key = string
        })
      })

      Proxy = object({
        Metrics = object({
          Server = object({
            CA = string

            Cert = string
            Key = string
          })

          Client = object({
            CA = string
          })
        })

        Server = object({
          CA = string

          Cert = string
          Key = string
        })
      })
    })

    Secrets = object({
      CookieSecret = string
      SharedSecret = string

      SigningKey = string
    })
  })
}

#
# CoTurn
#

variable "CoTurn" {
  type = object({
    CoTurn = object({
      Realm = string
    })

    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })
  })
}

#
# Metrics
#

variable "Metrics" {
  type = object({
    Cortex = object({
      Consul = object({
        Hostname = string
        Port = number

        Token = string
    
        Prefix = string
      })

      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })

      Targets = map(object(
        {
          name = string
          count = number

          resources = object({
            cpu = number
            memory = number
            memory_max = number
          })
        }
      ))

      S3 = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })


        Bucket = string
      })

      AlertManagerBucket = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })


        Bucket = string
      })
    })

    SMTP = object({
      Server = string
      Port = string

      Username = string
      Password = string
    })

    Prometheus = object({
      Grafana = object({
        CA = string
      })

      CoreVault = object({
        Token = string
      })

      Vault = object({
        Token = string
      })

      Minio = object({
        AccessToken = string
      })

      HomeAssistant = object({
        AccessToken = string

        CA = string  
      })
    })

    MikroTik = object({
      Devices = map(object(
        {
          IPAddress = string

          Username = string
          Password = string
        }
      ))
    })

    iDRAC = object({
      Username = string
      Password = string

      Devices = map(object(
        {
          IPAddress = string
        }
      ))
    })

    MSTeams = object({
      Webhook = string
    })
  })
}

variable "Misc" {
  type = object({
    Ivatar = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })

      OpenID = object({
        ClientID = string
        ClientSecret = string
      })
    })
  })
}

#
# Logs Stack
#
variable "Logs" {
  type = object({
    Loki = object({
      Consul = object({
        Hostname = string
        Port = number

        Token = string
    
        Prefix = string
      })

      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })

      Targets = map(object(
        {
          name = string
          count = number

          resources = object({
            cpu = number
            memory = number
            memory_max = number
          })
        }
      ))

      S3 = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })


        Bucket = string
      })
    })
  })
}
 
#
# Tracing Stack
#
variable "Tracing" {
  type = object({
    Tempo = object({
      Consul = object({
        Hostname = string
        Port = number

        Token = string
    
        Prefix = string
      })

      S3 = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })


        Bucket = string
      })
    })

  })
}

#
# NAS Storage
# 

variable "Storage" {
  type = object({
    NAS = object({
      Hostname = string

      Admin = object({
        Hostname = string
      })

      Password = string

    })

    Minio = object({
      AccessKey = string
      SecretKey = string

      AccessToken = string
    })
  })
}

#
# Inventory
#

variable "Inventory" {
  type = object({
    #
    # Netbox DCIM
    #
    Netbox = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })

      Admin = object({
        Username = string

        Email = string
      })

      Token = string
    })
    
    #
    # MeshCentral Mobility Management
    #
    MeshCentral = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })
    })

  })
}

########################
#       Network        #
########################

variable "Network" {
  type = object({
    Monitoring = object({
      OpenNMS = object({
        Database = object({
          Hostname = string
          Port = number

          Database = string

          Username = string
          Password = string
        })
      })

      # Oxidized = object({
      #   Git = object({
      #     Repo = object({
      #       URI = string
      #     })

      #     Credentials = object({
      #       Username = string
      #       Password = string
      #     })
      #   })
      # })
    })
  })
}

#
# DHCP
#
variable "DHCP" {
  type = object({
    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    TLS = object({
      CA = string
    })
  })
}

#
# DNS
# 
# Recursive and Dynamic DNS Servers
#
variable "DNS" {
  type = object({
    Consul = object({
      Hostname = string
      Port = number
  
      Token = string
    })
  })
}

#
# NS
#
variable "NS" {
  type = object({
    PowerDNS = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })
    })

    PowerDNSAdmin = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })
    })
  })

  description = "Configuration for Authoritative NS Servers"
}

#
# ENMS
#

variable "ENMS" {
  type = object({
    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    # Vault = object({

    # })

    Repo = object({
      URI = string

      Token = string
    })
  })
}

#
# Communications
#

variable "Communications" {
  type = object({
    Mattermost = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })

      GitLab = object({
        ClientID = string
        ClientSecret = string
      })

      S3 = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })


        Bucket = string
      })
    })

  })
}

#
# Databases
# 

variable "Databases" {
  type = object({
    MongoDB = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })
    })
  })
}

#
# Servers
#

variable "Servers" {
  type = object({
    Rancher = object({
      OpenID = object({
        ClientID = string
        ClientSecret = string
      })

      LDAP = object({
        Username = string
        Password = string
      })
    })

    HashUI = object({
      OpenID = object({
        ClientID = string
        ClientSecret = string
      })

      LDAP = object({
        Username = string
        Password = string
      })
    })

    Tinkerbell = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })

      TLS = object({
        CA = string

        Tink = object({
          Cert = string
          Key = string
        })

        Hegel = object({
          Cert = string
          Key = string
        })
      
        Registry = object({
          Cert = string
          Key = string
        })
      })

      Boots = object({
        Registry = object({
          Username = string
          Password = string
        })
      })
    })
  })
}

#
# NextCloud
#
variable "NextCloud" {
  type = object({
    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    Credentials = object({
      Username = string

      Token = string
    })

    S3 = object({
      Connection = object({
        Hostname = string
        Port = number

        Endpoint = string
      })

      Credentials = object({
        AccessKey = string
        SecretKey = string
      })


      Bucket = string
    })
  })
}

#
# eJabberD
#

variable "eJabberD" {
  type = object({
    OpenID = object({
      ClientID = string
      ClientSecret = string
    })

    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    LDAP = object({
      Username = string

      Password = string
    })

    TLS = object({
      CA = string

      MQTT = object({
        Cert = string

        Key = string
      })

      Server = object({
        Cert = string

        Key = string
      })

      Redis = object({
        Cert = string

        Key = string
      })
    })
  })
}

#
# OpenProject
#

variable "OpenProject" {
  type = object({
    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    OpenID = object({
      ClientID = string
      ClientSecret = string
    })

    S3 = object({
      Connection = object({
        Hostname = string
        Port = number

        Endpoint = string
      })

      Credentials = object({
        AccessKey = string
        SecretKey = string
      })


      Bucket = string
    })

    SMTP = object({
      Server = string
      Port = string

      Username = string
      Password = string
    })
  })
}


#
# HomeAssistant
#
variable "HomeAssistant" {
  type = object({
    OpenID = object({
      ClientID = string
      ClientSecret = string
    })

    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    MQTT = object({
      Connection = object({
        Hostname = string
        Port = number

        CA = string
      })

      Credentials = object({
        Username = string
        Password = string
      })
    })

    Secrets = object({
      HomeLocation = object({
        HomeLatitude = string
        HomeLongitude = string
      })
    })

    TLS = object({
      CA = string

      Server = object({
        Cert = string
        Key = string
      })
    })
  })
}

#
# Cache
#
variable "Cache" {
  type = object({
    Pomerium = object({
      RedisCache = object({
        TLS = object({
          CA = string

          Cert = string
          Key = string
        })
      })
    })
  })
}

#
# Development
#

#
# GitLab
#

variable "GitLab" {
  type = object({
    Database = object({
      Core = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })

      Praefect = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })
    })

    LDAP = object({
      Credentials = object({
        Username = string
        Password = string
      })
    })

    Secrets = object({
      OpenIDSigningKey = string
    })

    TLS = object({
      WebService = object({
        CA = string

        Cert = string
        Key = string
      })

      WorkHorse = object({
        CA = string

        Cert = string
        Key = string
      })

      Registry = object({
        CA = string

        Cert = string
        Key = string
      })
    })

    S3 = object({
      ArtifactsBucket = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })

        Bucket = string
      })

      ExternalDiffsBucket = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })

        Bucket = string
      })
    
      RepoBucket = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })

        Bucket = string
      })

      LFSBucket = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })

        Bucket = string
      })

      UploadsBucket = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })

        Bucket = string
      })

      PackagesBucket = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })

        Bucket = string
      })

      DependencyProxyBucket = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })

        Bucket = string
      })

      TerraformStateBucket = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })

        Bucket = string
      })

      PagesBucket = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })

        Bucket = string
      })
    })

    OpenID = object({
      ClientID = string

      ClientSecret = string
    })

    SMTP = object({
      Server = string
      Port = string

      Username = string
      Password = string
    })
  })
}

###########################
#        Education        #
###########################

variable "Education" {
  type = object({
    Moodle = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })

      OpenID = object({
        ClientID = string
        ClientSecret = string
      })

      S3 = object({
        Repository = object({
          Connection = object({
            Hostname = string
            Port = number

            Endpoint = string
          })

          Credentials = object({
            AccessKey = string
            SecretKey = string
          })


          Bucket = string
        })
      })

      TLS = object({
        CA = string

        CoreServer = object({
          CA = string

          Cert = string
          Key = string
        })
      })
    })
  })
}

#
# Ingress
#
variable "Ingress" {
  type = object({
    GoBetween = object({
      Consul = object({
        Hostname = string
        Port = number
  
        Token = string
      })
    })
  })
}

#
# Harbor
# 

variable "Registry" {
  type = object({
    Harbor = object({
      S3 = object({
        Images = object({
          Connection = object({
            Hostname = string
            Port = number

            Endpoint = string
          })

          Credentials = object({
            AccessKey = string
            SecretKey = string
          })


          Bucket = string
        })

        Charts = object({
          Connection = object({
            Hostname = string
            Port = number

            Endpoint = string
          })

          Credentials = object({
            AccessKey = string
            SecretKey = string
          })


          Bucket = string
        })
      })

      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })

      TLS = object({
        CA = string

        Core = object({
          Cert = string

          Key = string
        })

        JobService = object({
          Cert = string

          Key = string
        })

        Portal = object({
          Cert = string

          Key = string
        })

        Registry = object({
          Cert = string

          Key = string
        })

        GitLabRegistry = object({
          Cert = string

          Key = string
        })

        GitLabRegistryCTL = object({
          Cert = string

          Key = string
        })

        RegistryCTL = object({
          Cert = string

          Key = string
        })

        Exporter = object({
          Cert = string

          Key = string
        })

        ChartMuseum = object({
          CA = string

          Cert = string
          Key = string
        })
      })
    })
  })
}

#
# Search
#

variable "Search" {
  type = object({
    OpenSearch = object({
      OpenID = object({
        ClientID = string
        ClientSecret = string
      })

      TLS = object({
        CA = string

        Coordinator = object({
          Coordinator0 = object({
            CA = string

            Cert = string
            Key = string
          })

          Coordinator1 = object({
            CA = string

            Cert = string
            Key = string
          })

          Coordinator2 = object({
            CA = string

            Cert = string
            Key = string
          })
        })

        Ingest = object({
          Ingest0 = object({
            CA = string

            Cert = string
            Key = string
          })

          Ingest1 = object({
            CA = string

            Cert = string
            Key = string
          })

          Ingest2 = object({
            CA = string

            Cert = string
            Key = string
          })
        })

        Master = object({
          Master0 = object({
            CA = string

            Cert = string
            Key = string
          })

          Master1 = object({
            CA = string

            Cert = string
            Key = string
          })

          Master2 = object({
            CA = string

            Cert = string
            Key = string
          })
        })

        Data = object({
          Data0 = object({
            CA = string

            Cert = string
            Key = string
          })

          Data1 = object({
            CA = string

            Cert = string
            Key = string
          })

          Data2 = object({
            CA = string

            Cert = string
            Key = string
          })

          Data3 = object({
            CA = string

            Cert = string
            Key = string
          })

          Data4 = object({
            CA = string

            Cert = string
            Key = string
          })

          Data5 = object({
            CA = string

            Cert = string
            Key = string
          })
        })
      })

      S3 = object({
        CoreRepo = object({
          Connection = object({
            Hostname = string
            Port = number

            Endpoint = string
          })

          Credentials = object({
            AccessKey = string
            SecretKey = string
          })

          Bucket = string
        })
      })
    })

    SourceGraph = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })
    })
  })
}

#
# Mesh
#

# variable "Mesh" {
#   type = object({
#     Meshery = object({
#       Consul = object({
#         Hostname = string
#         Port = number
  
#         Token = string
#       })
#     })
#   })
  
# }

#
# Security
#

variable "Security" {
  type = object({
    ThreatMapper = object({
      Database = object({
        Fetcher = object({
          Hostname = string
          Port = number

          Database = string

          Username = string
          Password = string
        })

        User = object({
          Hostname = string
          Port = number

          Database = string

          Username = string
          Password = string
        })
      })
    })
  })
}

#
# Business
#
variable "Business" {
  type = object({
    Vikunja = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })

      OpenID = object({
        ClientID = string

        ClientSecret = string
      })

      SMTP = object({
        Server = string
        Port = string

        Username = string
        Password = string
      })
    })

    Outline = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })

      OpenID = object({
        ClientID = string

        ClientSecret = string
      })

      S3 = object({
        Connection = object({
          Hostname = string
          Port = number

          Endpoint = string
        })

        Credentials = object({
          AccessKey = string
          SecretKey = string
        })


        Bucket = string
      })

      SMTP = object({
        Server = string
        Port = string

        Username = string
        Password = string
      })
    })

    ReadFlow = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })
    })

    Zammad = object({
      Database = object({
        Hostname = string
        Port = number

        Database = string

        Username = string
        Password = string
      })

      SMTP = object({
        Server = string
        Port = string

        Username = string
        Password = string
      })
    })
  })
}

#
# Workflows
#

# variable "Workflow" {
#   type = object({
#     N8N = object({
#       Database = object({
#         Hostname = string
#         Port = number

#         Database = string

#         Username = string
#         Password = string
#       })
#     })

#   })
# }