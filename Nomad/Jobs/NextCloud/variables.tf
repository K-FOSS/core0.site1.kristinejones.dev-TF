variable "Database" {
  type = object({
    Hostname = string

    Username = string
    Password = string

    Database = string
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