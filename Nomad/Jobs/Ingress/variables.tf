variable "GoBetween" {
  type = object({
    Consul = object({
      Hostname = string
      Port = number

      Token = string
    })
  })
}