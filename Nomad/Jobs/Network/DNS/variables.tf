variable "Netbox" {
  type = object({
    Hostname = string
    Port = number

    Token = string
  })
}

variable "Consul" {
  type = object({
    Hostname = string
    Port = number

    Token = string
  })
}
