variable "Netbox" {
  type = object({
    Hostname = string
    Port = number

    Token = string
  })
  
  sensitive = true
}