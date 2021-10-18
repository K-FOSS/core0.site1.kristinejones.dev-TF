variable "Netbox" {
  type = object({
    Hostname = string
    Port = number

    Token = string
  })
  
  sensitive = true
}

variable "Consul" {
  type = object({
    Hostname = string
    Port = number

    Token = string
  })
  
  sensitive = true
}

#
# PowerDNS
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
  
  sensitive = true
}
