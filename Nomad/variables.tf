variable "Bitwarden" {
  value = object({
    Database = object({
      Hostname = string

      Username = string
      Password = string

      Database = string
    })
  })
}