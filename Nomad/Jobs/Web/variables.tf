variable "Consul" {
  type = object({
    Token = string
    EncryptionKey = string
  })
}

variable "CloudFlare" {
  type = object({
    Token = string
  })
}