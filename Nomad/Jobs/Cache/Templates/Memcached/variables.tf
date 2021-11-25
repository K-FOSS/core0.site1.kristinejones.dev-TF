variable "Service" {
  value = object({
    Name = string

    Consul = object({
      ServiceName = string
    })
  })
}