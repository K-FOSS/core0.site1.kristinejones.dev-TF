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

variable "Pomerium" {
  type = object({
    CA = string
  })
}

variable "Harbor" {
  type = object({
    CA = string
  })
}