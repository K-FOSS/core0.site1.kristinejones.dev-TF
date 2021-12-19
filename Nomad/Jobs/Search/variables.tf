variable "OpenSearch" {
  type = object({
    OpenID = object({
      ClientID = string
      ClientSecret = string
    })

    TLS = object({
      CA = string

      OpenSearch0 = object({
        CA = string

        Cert = string
        Key = string
      })

      OpenSearch1 = object({
        CA = string

        Cert = string
        Key = string
      })
    })

    S3 = object({
      CoreRepo = object({
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
    })
  })
  
}