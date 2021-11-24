variable "OpenID" {
  type = object({
    ClientID = string
    ClientSecret = string
  })
}

variable "TLS" {
  type = object({
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
}

variable "Secrets" {
  type = object({
    CookieSecret = string
    SharedSecret = string
  })
}