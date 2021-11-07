variable "OpenID" {
  type = object({
    ClientID = string
    ClientSecret = string
  })
}

variable "TLS" {
  type = object({
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
}

variable "Authenticate" {
  type = object({
    TLS = object({
      Cert = string

      Key = string
    })
  })
}

variable "Authorize" {
  type = object({
    TLS = object({
      Cert = string

      Key = string
    })
  })
}

variable "DataBroker" {
  type = object({
    TLS = object({
      Cert = string

      Key = string
    })
  })
}

variable "Proxy" {
  type = object({
    TLS = object({
      Cert = string

      Key = string
    })
  })
}

variable "Secrets" {
  type = object({
    CookieSecret = string
    SharedSecret = string
  })
}