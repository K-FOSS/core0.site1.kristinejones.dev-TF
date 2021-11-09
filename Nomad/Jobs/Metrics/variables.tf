#
# Grafana Cortex
#

variable "Cortex" {
  type = object({
    Consul = object({
      Hostname = string
      Port = number

      Token = string
    
      Prefix = string
    })

    Database = object({
      Hostname = string
      Port = number

      Database = string

      Username = string
      Password = string
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

#
# MikroTik Exporter
#
variable "MikroTik" {
  type = object({
    Devices = map(object(
      {
        IPAddress = string

        
        Username = string
        Password = string
      }
    ))
  })
}

# variable "iDRAC" {
#   type = object({
#     Devices = map(object(
#       {
#         IPAddress = string

        
#         Username = string
#         Password = string
#       }
#     ))
#   })
# }