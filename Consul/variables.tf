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


#
# Cortex
#

variable "Cortex" {
  type = object({
    Prefix = string
  })
  sensitive = true

  description = "Cortex Configuration"
}

#
# Loki
#

variable "Loki" {
  type = object({
    Prefix = string
  })
  sensitive = true

  description = "Loki Configuration"
}

#
# Tempo
#
variable "Tempo" {
  type = object({
    Prefix = string
  })
  sensitive = true

  description = "Tempo Configuration"
}
