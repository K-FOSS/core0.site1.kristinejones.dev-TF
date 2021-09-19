variable "Bitwarden" {
  type = object({
    Database = object({
      Hostname = string

      Username = string
      Password = string

      Database = string
    })
  })
}

variable "Ingress" {
  type = object({
    Consul = object({
      Token = string
      EncryptionKey = string
    })
    Cloudflare = object({
      Token = string
    })
  })
}