variable "Consul" {
  type = object({
    Hostname = string
    Port = number

    Token = string
    
    Prefix = string
    ServiceName = string
  })
}