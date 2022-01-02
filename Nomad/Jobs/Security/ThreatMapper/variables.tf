#
# Database
#

variable "Database" {
  type = object({
    Fetcher = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    User = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })
  })
}

#
# TLS
#

variable "TLS" {
  type = object({
    CA = string

    UI = {
      CA = string

      Cert = string
      Key = string
    }
  })
}

#
# Storage
#

#
# Auth
#

#
# OpenID
# 

#
# LDAP?
#

#
# Notifications
#