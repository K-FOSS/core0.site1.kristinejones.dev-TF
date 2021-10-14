variable "Loki" {
  type = object({
    Consul = object({
      Hostname = string
      Port = number

      Token = string
    
      Prefix = string
    })

    Targets = map(object(
      {
        name = string
        count = number
      }
    ))

    S3 = object({
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

variable "Cortex" {
  type = object({
    Consul = object({
      Hostname = string
      Port = number

      Token = string
    
      Prefix = string
    })

    Targets = map(object(
      {
        name = string
        count = number

        resources = object({
          cpu = number
          memory = number
          memory_max = number
        })
      }
    ))

    S3 = object({
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


variable "Tempo" {
  type = object({
    Consul = object({
      Hostname = string
      Port = number

      Token = string
    
      Prefix = string
    })

    Targets = map(object(
      {
        name = string
        count = number
      }
    ))

    S3 = object({
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

variable "Prometheus" {
  type = object({
    Grafana = object({
      CA = string
    })

    CoreVault = object({
      Token = string
    })

    Vault = object({
      Token = string
    })
  })
}