variable "Bitwarden" {
  type = object({
    Database = object({
      Hostname = string

      Username = string
      Password = string

      Database = string
    })
  })
}