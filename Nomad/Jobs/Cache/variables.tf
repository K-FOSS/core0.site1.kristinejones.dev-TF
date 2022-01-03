#
# AAA
#

variable "AAA" {
  type = object({
    Teleport = object({
      CA = string
    
      ETCD = object({
        CA = string

        Cert = string
        Key = string
      })
    })
  })
}


# variable "GitHub" {
#   type = object({
#     Credentials = object({
#       Token = string
#     })
#   })

#   description = "GitHub Cache Credentials"
# }

#
# OpenProject
#

# variable "OpenProject" {
#   type = object({
#     RedisCache = object({
#       TLS = object({
#         CA = string

#         Cert = string
#         Key = string
#       })
#     })
#   })
# }

#
# Authentik
#

# variable "Authentik" {
#   type = object({
#     RedisCache = object({
#       TLS = object({
#         CA = string

#         Cert = string
#         Key = string
#       })
#     })
#   })
# }

#
# Pomerium
#

variable "Pomerium" {
  type = object({
    RedisCache = object({
      TLS = object({
        CA = string

        Cert = string
        Key = string
      })
    })
  })
}

#
# eJabberD
#

variable "eJabberD" {
  type = object({
    Redis = object({
      Password = string
    })
  })
}

#
# Inventory
# 

#
# IPAM
# 

variable "IPAM" {
  type = object({
    Netbox = object({
      Redis = object({
        Cache = object({
          Password = string
        })

        General = object({
          Password = string
        })
      })
    })
  })
}