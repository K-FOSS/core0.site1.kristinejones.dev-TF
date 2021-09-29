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

    Cert = string
    Key = string
  })
}