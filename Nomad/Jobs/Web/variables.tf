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

variable "HomeAssistant" {
  type = object({
    CA = string
  })
}

variable "Bitwarden" {
  type = object({
    CA = string
  })
}