job "Bitwarden" {
  datacenters = ["core0site1"]

  group "Vault" {
    count = 1

    network {
      mode = "bridge"

      port "http" { }
    }

    service {
      name = "bitwarden-cont"
      port = "http"

      task = "vault"

      connect {
        sidecar_service {}
      }
    }

    task "vault" {
      driver = "docker"

      config {
        image        = "vaultwarden/server:alpine"

        ports = ["http"]
      }

      env {
        WEBSOCKET_ENABLED = "true"
        ROCKET_PORT = "$${NOMAD_PORT_http}"
        DATABASE_URL = "postgresql://${Database.Username}:${Database.Password}@${Database.Hostname}:5432/${Database.Database}"
      }
    }
  }
}