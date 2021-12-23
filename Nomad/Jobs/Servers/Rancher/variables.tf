#
# OpenID
#
variable "OpenID" {
  type = object({
    ClientID = string
    ClientSecret = string
  })
}

#
# LDAP
#
variable "LDAP" {
  type = object({
    Username = string
    Password = string
  })
}