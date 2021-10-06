variable "Netbox" {
  type = object({
    Hostname = string
    Port = number

    Token = sensitive(string)
  })
}