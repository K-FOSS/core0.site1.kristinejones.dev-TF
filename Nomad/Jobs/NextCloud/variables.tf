variable "Database" {
  type = object({
    Hostname = string
    Port = number

    Database = string

    Username = string
    Password = string
  })
}

variable "S3" {
  type = object({
    Connection = object({
      Hostname = string
      Port = number

      Endpoint = string
    })

    Credentials = object({
      AccessKey = string
      SecretKey = string
    })

    Bucket = string
  })
}

variable "Credentials" {
  type = object({
    Username = string

    Token = string
  })
}