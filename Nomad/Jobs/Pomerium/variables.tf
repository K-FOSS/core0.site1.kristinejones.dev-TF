variable "OpenID" {
  type = object({
    ClientID = string
    ClientSecret = string
  })
}

variable "Secrets" {
  type = object({
    CookieSecret = string
    SharedSecret = string
  })
}

variable "TLS" {
  type = object({
    CA = string

    Proxy = object({
      Cert = string
      Key = string
    })

    DataBroker = object({
      Cert = string
      Key = string
    })

    Authenticate = object({
      Cert = string
      Key = string
    })

    Authorize = object({
      Cert = string
      Key = string
    })
  })
}

variable "Services" {
  type = map(object(
    {
      Name = string
      Count = number

      TLS = object({
        Cert = string

        Key = string
      })
    }
  ))
}