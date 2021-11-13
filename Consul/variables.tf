#
# Patroni Database
#

variable "Patroni" {
  type = object({
    Prefix = string
    ServiceName = string
  })

  description = "Patroni Configuration"
}

#
# Grafana Observability
#


#
# Cortex
#

variable "Cortex" {
  type = object({
    Prefix = string
  })

  description = "Cortex Configuration"
}

#
# Loki
#

variable "Loki" {
  type = object({
    Prefix = string
  })

  description = "Loki Configuration"
}

#
# Tempo
#
variable "Tempo" {
  type = object({
    Prefix = string
  })

  description = "Tempo Configuration"
}

#
# HomeAssistant
#

variable "HomeAssistant" {
  type = object({
    TLS = object({
      CA = string

      Cert = string
      Key = string
    })

    Connection = object({
      Hostname = string
      Port = number
    })
  })

  description = "HomeAssistant Configuration"
}
