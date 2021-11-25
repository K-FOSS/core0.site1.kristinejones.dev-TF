variable "Service" {
  type = object({
    Name = string

    Consul = object({
      ServiceName = string
    })
  })
}