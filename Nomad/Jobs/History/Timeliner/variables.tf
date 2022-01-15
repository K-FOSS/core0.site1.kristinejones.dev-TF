variable "S3" {
  type = object({
    Database = object({
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
  })
}