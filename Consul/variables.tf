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

variable "Cortex" {
  type = object({
    Prefix = string
  })
  sensitive = true

  description = "Cortex Configuration"
}