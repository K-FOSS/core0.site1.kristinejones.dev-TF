variable "Database" {
  type = object({
    Hostname = string
    Port = number

    Database = string

    Username = string
    Password = string
  })
}

#
# AAA
#

#
# OpenID
#

variable "OpenID" {
  type = object({
    ClientID = string

    ClientSecret = string
  })
}

#
# Storage
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
# Email
#

#
# SMTP
#

variable "SMTP" {
  type = object({
    Server = string
    Port = string

    Username = string
    Password = string
  })
}