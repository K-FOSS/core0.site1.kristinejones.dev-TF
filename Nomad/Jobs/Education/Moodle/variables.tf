#################
#    Storage    #
#################

#
# Data
#

variable "Database" {
  type = object({
    Core = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })
  })
}

#
# Object Storage
#

variable "S3" {
  type = object({
    Repository = object({
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
}



# variable "LDAP" {
#   type = object({
#     Credentials = object({
#       Username = string
#       Password = string
#     })
#   })
# }

variable "TLS" {
  type = object({
    CA = string

    CoreServer = object({
      CA = string

      Cert = string
      Key = string
    })
  })
}