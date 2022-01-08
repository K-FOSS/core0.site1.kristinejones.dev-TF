#
# Storage
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
# LDAP
#

variable "LDAP" {
  type = object({
    Credentials = object({
      Username = string
      Password = string
    })
  })
}