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
# GitLab
#