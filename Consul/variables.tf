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