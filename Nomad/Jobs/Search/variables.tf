variable "OpenSearch" {
  type = object({
    OpenID = object({
      ClientID = string
      ClientSecret = string
    })

    TLS = object({
      CA = string

      Coordinator = object({
        Coordinator0 = object({
          CA = string

          Cert = string
          Key = string
        })

        Coordinator1 = object({
          CA = string

          Cert = string
          Key = string
        })

        Coordinator2 = object({
          CA = string

          Cert = string
          Key = string
        })
      })

      Ingest = object({
        Ingest0 = object({
          CA = string

          Cert = string
          Key = string
        })

        Ingest1 = object({
          CA = string

          Cert = string
          Key = string
        })

        Ingest2 = object({
          CA = string

          Cert = string
          Key = string
        })
      })

      Master = object({
        Master0 = object({
          CA = string

          Cert = string
          Key = string
        })

        Master1 = object({
          CA = string

          Cert = string
          Key = string
        })

        Master2 = object({
          CA = string

          Cert = string
          Key = string
        })
      })

      Data = object({
        Data0 = object({
          CA = string

          Cert = string
          Key = string
        })

        Data1 = object({
          CA = string

          Cert = string
          Key = string
        })

        Data2 = object({
          CA = string

          Cert = string
          Key = string
        })

        Data3 = object({
          CA = string

          Cert = string
          Key = string
        })

        Data4 = object({
          CA = string

          Cert = string
          Key = string
        })

        Data5 = object({
          CA = string

          Cert = string
          Key = string
        })
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