variable "Database" {
  type = object({
    Hostname = string
    Port = number

    Database = string

    Username = string
    Password = string
  })
}


variable "OpenID" {
  type = object({
    URL = string

    ClientID = string
    ClientSecret = string
  })
}
