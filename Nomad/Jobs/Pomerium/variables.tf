variable "OpenID" {
  type = object({
    ClientID = string
    ClientSecret = string
  })
}

variable "Secrets" {
  type = object({
    CookieSecret = string
    SharedSecret = string
  })
}

variable "Services" {
  type = map(object(
    {
      name = string
      count = number
    }
  ))
}