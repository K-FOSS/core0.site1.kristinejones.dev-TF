variable "Ivatar" {
  type = object({
    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    OpenID = object({
      ClientID = string
      ClientSecret = string
    })
  })
}

#
# ShareX
#

variable "ShareX" {
  type = object({
    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

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

    LDAP = object({
      Credentials = object({
        Username = string
        Password = string
      })
    })
  })
}