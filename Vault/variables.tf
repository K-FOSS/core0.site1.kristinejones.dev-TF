#
# OpenID Clients
#

#
# Pomerium Proxy
#
variable "Pomerium" {
  type = object({
    VaultPath = string
  })
}

#
# eJabberD
#
variable "eJabberD" {
  type = object({
    OIDVaultPath = string
  })
}

#
# Tinkerbell
#

variable "Tinkerbell" {
  type = object({
    Admin = object({
      Username = string
      Password = string
    })
  })
}