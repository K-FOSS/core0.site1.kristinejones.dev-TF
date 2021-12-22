#
# PostgreSQL Database Configuration
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
# Misc
#
variable "Domain" {
  type = string
}

variable "Secrets" {
  type = object({
    SecretKey = string
  })
}

variable "LDAP" {
  type = object({
    AuthentikHost = string
    AuthentikToken = string
  })
}

variable "SMTP" {
  type = object({
    Server = string
    Port = string

    Username = string
    Password = string
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