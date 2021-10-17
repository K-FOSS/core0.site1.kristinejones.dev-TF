#
# Bitwarden
# 

variable "Bitwarden" {
  type = object({
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
# Caddy Web Ingress
#

variable "Ingress" {
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
  sensitive = true

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
    })

    Services = map(object(
      {
        Name = string
        Count = number

        TLS = object({
          Cert = string

          Key = string
        })
      }
    ))

    Secrets = object({
      CookieSecret = string
      SharedSecret = string
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

    Tempo = object({
      Consul = object({
        Hostname = string
        Port = number

        Token = string
    
        Prefix = string
      })

      Targets = map(object(
        {
          name = string
          count = number
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

    Loki = object({
      Consul = object({
        Hostname = string
        Port = number

        Token = string
    
        Prefix = string
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
  })
}

#
# Netbox 
#
variable "Netbox" {
  type = object({
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
  })
}

#
# Mattermost
#

variable "Mattermost" {
  type = object({
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
# Tinkerbell
#

variable "Tinkerbell" {
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

      Tink = object({
        Cert = string
        Key = string
      })

      Hegel = object({
        Cert = string
        Key = string
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

# variable "OpenProject" {
#   type = object({
#     Database = object({
#       Hostname = string
#       Port = number

#       Database = string

#       Username = string
#       Password = string
#     })

#     S3 = object({
#       Connection = object({
#         Hostname = string
#         Port = number

#         Endpoint = string
#       })

#       Credentials = object({
#         AccessKey = string
#         SecretKey = string
#       })


#       Bucket = string
#     })
#   })
# }


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