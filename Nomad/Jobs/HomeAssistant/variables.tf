variable "Database" {
  type = object({
    Hostname = string
    Port = number

    Database = string

    Username = string
    Password = string
  })
}

variable "OpenID" {
  type = object({
    ClientID = string
    ClientSecret = string
  })
}

variable "TLS" {
  type = object({
    CA = string

    Server = object({
      Cert = string
      Key = string
    })
  })
}

variable "MQTT" {
  type = object({
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
}

variable "Secrets" {
  type = object({
    HomeLocation = object({
      HomeLatitude = string
      HomeLongitude = string
    })
  })
}