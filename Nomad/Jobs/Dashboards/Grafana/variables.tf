variable "Database" {
  type = object({
    Hostname = string
    Port = number

    Database = string

    Username = string
    Password = string
  })
}

variable "TLS" {
  type = object({
    CA = string

    Cert = string
    Key = string
  })
}