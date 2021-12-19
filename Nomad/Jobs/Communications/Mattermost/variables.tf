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

variable "GitLab" {
  type = object({
    ClientID = string
    ClientSecret = string

    URL = string
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