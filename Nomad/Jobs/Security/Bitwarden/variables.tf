#
# Data
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
# Security/mTLS
#

variable "TLS" {
  type = object({
    CA = string

    Server = object({
      Cert = string
      Key = string
    })
  })
}

#
# Email
#
variable "SMTP" {
  type = object({
    Server = string
    Port = string

    Username = string
    Password = string
  })
}