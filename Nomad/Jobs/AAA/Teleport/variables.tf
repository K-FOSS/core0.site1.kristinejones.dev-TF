#
# Auth
#
variable "OpenID" {
  type = object({
    URL = string

    ClientID = string
    ClientSecret = string
  })
}
