variable "Database" {
  type = object({
    Hostname = string

    Username = string
    Password = string

    Database = string
  })
}

variable "Admin" {
  type = object({
    Username = string

    Email = string
  })
}

