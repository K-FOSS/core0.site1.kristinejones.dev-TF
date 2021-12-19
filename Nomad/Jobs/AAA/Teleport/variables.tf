#
# Auth
#

variable "OpenID" {
  type = object({
    ClientID = string
    ClientSecret = string
  })
}

#
# TLS
#
variable "TLS" {
  type = object({
    CA = string

    ETCD = object({
      CA = string

      Cert = string
      Key = string
    })

    Proxy = object({
      CA = string

      Cert = string
      Key = string
    })

    Auth = object({
      CA = string

      Cert = string
      Key = string
    })

    Tunnel = object({
      CA = string

      Cert = string
      Key = string
    })

    Kube = object({
      CA = string

      Cert = string
      Key = string
    })
  })
}