variable "TLS" {
  type = object({
    Proxy = object({
      Cert = string
      Key = string
    })

    DataBroker = object({
      Cert = string
      Key = string
    })

    Authenticate = object({
      Cert = string
      Key = string
    })

    Authorize = object({
      Cert = string
      Key = string
    })
  })
}