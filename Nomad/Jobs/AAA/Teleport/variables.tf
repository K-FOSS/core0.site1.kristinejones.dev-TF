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
# S3
#
variable "S3" {
  type = object({
    Connection = object({
      Hostname = string
      Port = number

      Endpoint = string
    })

    Credentials = object({
      AccessKey = string
      SecretKey = string
    })

    Bucket = string
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