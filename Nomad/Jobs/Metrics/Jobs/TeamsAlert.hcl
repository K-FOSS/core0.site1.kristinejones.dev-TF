job "teams-alert" {
  datacenters = ["core0site1"]

  group "msteams-alert-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "alerts" {
        to = 8089 
      }
    }

    service {
      name = "msteams"
      port = "alerts"

      task = "prom2teams-alerts"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "alerts"]
    }

    task "prom2teams-alerts" {
      driver = "docker"

      config {
        image = "idealista/prom2teams"
      }

      template {
        data = <<EOH
PROM2TEAMS_CONNECTOR="${Teams.Webhook}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }
}