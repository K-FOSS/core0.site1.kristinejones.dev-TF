variable "Harbor" {
  type = object({
    S3 = object({
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

    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    #
    # TODO: OpenID
    #

    #
    # OpenID = object({
    #   ClientID = string
    #   ClientSecret = string
    #   MetadataURL = string
    #})
    #

    TLS = object({
      CA = string

      Core = object({
        Cert = string

        Key = string
      })

      JobService = object({
        Cert = string

        Key = string
      })

      Portal = object({
        Cert = string

        Key = string
      })

      Registry = object({
        Cert = string

        Key = string
      })

      RegistryCTL = object({
        Cert = string

        Key = string
      })

      Exporter = object({
        Cert = string

        Key = string
      })
    })
  })
}