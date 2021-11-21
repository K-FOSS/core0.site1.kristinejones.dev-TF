variable "CoTurn" {
  type = object({
    Realm = string

    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
    })
  })
}