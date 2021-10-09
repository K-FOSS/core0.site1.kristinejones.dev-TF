variable "TLS" {
  type = object({
    CA = string

    Server = object({
      Cert = string
      Key = string
    })

    MQTT = object({
      Cert = string
      Key = string
    })

    Redis = object({
      Cert = string
      Key = string
    })
  })
}

variable "Database" {
  type = object({
    Hostname = string

    Username = string
    Password = string

    Database = string
  })
}

variable "OpenID" {
  type = object({
    ClientID = string
    ClientSecret = string
  })
}