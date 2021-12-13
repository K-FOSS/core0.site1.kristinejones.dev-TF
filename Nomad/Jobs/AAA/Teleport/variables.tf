#
# Auth
#
variable "OpenID" {
  type = object({
    ClientID = string
    ClientSecret = string
  })
}
