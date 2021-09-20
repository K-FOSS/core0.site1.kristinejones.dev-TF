variable "Credentials" {
  type = object({
    Hostname = string
    Port = number

    Username = string
    Password = string
  })
}