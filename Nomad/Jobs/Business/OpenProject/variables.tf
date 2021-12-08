#
# PostgreSQL Database
#

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
# Auth
#

variable "OpenID" {
  type = object({
    ClientID = string
    ClientSecret = string
  })
}

#
# S3 Uploads Bucket
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

variable "Admin" {
  type = object({
    Username = string

    Email = string
  })
}

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