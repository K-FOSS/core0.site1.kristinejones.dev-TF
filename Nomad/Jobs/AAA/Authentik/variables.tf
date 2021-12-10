#
# PostgreSQL Database Configuration
# 

variable "Database" {
  type = object({
    Hostname = string
    Port = number

    Database = string

    Username = string
    Password = string
  })
}

variable "Secrets" {
  type = object({
    SecretKey = string
  })
}

variable "LDAP" {
  type = object({
    AuthentikHost = string
    AuthentikToken = string
  })
}

variable "SMTP" {
  type = object({
    Server = string
    Port = string

    Username = string
    Password = string
  })
}