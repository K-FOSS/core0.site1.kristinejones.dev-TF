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