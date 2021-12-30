#
# Storage
#

#
# PostgreSQL
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