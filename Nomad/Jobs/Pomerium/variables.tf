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

variable "TLS" {
  type = object({
    CA = string

    Redis = object({
      Cert = string

      Key = string
    })
  })
}

variable "Services" {
  type = map(object(
    {
      Name = string
      Count = number

      TLS = object({
        Cert = string

        Key = string
      })
    }
  ))
}