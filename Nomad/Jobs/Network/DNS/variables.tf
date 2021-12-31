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

#
# NS
#

variable "PowerDNS" {
  type = object({
    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })
  })
}