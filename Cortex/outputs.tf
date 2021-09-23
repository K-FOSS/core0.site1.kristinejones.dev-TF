output "Targets" {
  value = local.CORTEX_TARGETS

  description = "Map of all Cortex Services to deploy, and the number of scaled tasks"
} 