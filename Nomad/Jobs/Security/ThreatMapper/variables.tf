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