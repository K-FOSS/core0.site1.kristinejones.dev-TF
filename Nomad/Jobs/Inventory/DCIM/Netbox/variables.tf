variable "Database" {
  type = object({
    Hostname = string
    Port = number

    Database = string

    Username = string
    Password = string
  })
}

variable "Admin" {
  type = object({
    Username = string

    Email = string
  })
}

variable "Token" {
  type = string

  sensitive = true
}