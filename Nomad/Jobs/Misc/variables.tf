variable "Ivatar" {
  type = object({
    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })

    OpenID = object({
      ClientID = string
      ClientSecret = string
    })
  })
}