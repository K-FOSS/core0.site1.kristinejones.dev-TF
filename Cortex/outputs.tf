output "Targets" {
  #
  # TODO: Replace this with a loop to add "defaults" to allow for optional fields
  #
  value = local.CORTEX_TARGETS

  description = "Map of all Cortex Services to deploy, and the number of scaled tasks"
} 