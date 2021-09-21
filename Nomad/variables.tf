#
# Bitwarden
# 

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

#
# Caddy Web Ingress
#

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

#
# Grafana
#

variable "Grafana" {
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

#
# Patroni
#

variable "Patroni" {
  type = object({
    Consul = object({
      Hostname = string
      Port = number

      Token = string
    
      Prefix = string
      ServiceName = string
    })
  })
  sensitive = true

  description = "Patroni Configuration"
}