variable "Database" {
  type = object({
    Hostname = string

    Username = string
    Password = string

    Database = string
  })
}

variable "TLS" {
  type = object({
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
}