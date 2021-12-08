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

variable "OpenID" {
  type = object({
    ClientID = string

    ClientSecret = string
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