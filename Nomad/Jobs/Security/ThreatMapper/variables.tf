#
# Database
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