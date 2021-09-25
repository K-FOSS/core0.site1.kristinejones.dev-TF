#
# Patroni Database
#

variable "Patroni" {
  type = object({
    Prefix = string
    ServiceName = string
  })
  sensitive = true

  description = "Patroni Configuration"
}

#
# Grafana Observability
#

variable "Cortex" {
  type = object({
    Prefix = string
  })
  sensitive = true

  description = "Cortex Configuration"
}

variable "Loki" {
  type = object({
    Prefix = string
  })
  sensitive = true

  description = "Loki Configuration"
}

