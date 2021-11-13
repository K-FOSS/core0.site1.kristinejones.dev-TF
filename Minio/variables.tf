variable "Connection" {
  type = object({
    Hostname = string
    Port = string
  })

  description = "Minio credentials"
}

variable "Credentials" {
  type = object({
    AccessKey = string
    SecretKey = string
  })

  description = "Minio credentials"
}

