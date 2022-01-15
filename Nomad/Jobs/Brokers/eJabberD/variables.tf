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
    Port = number

    Database = string

    Username = string
    Password = string
  })
}

#
# AAA
#

variable "OpenID" {
  type = object({
    ClientID = string
    ClientSecret = string
  })
}

variable "LDAP" {
  type = object({
    Credentials = object({
      Username = string
      Password = string
    })
  })
}