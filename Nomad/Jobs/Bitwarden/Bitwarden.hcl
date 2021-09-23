job "bitwarden" {
  datacenters = ["core0site1"]

  group "bitwarden" {
    count = 1

    network {
      mode = "bridge"

      port "http" { }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
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
      }

      env {
        WEBSOCKET_ENABLED = "true"
        ROCKET_PORT = "$${NOMAD_PORT_http}"
        DATABASE_URL = "postgresql://${Database.Username}:${Database.Password}@${Database.Hostname}:5432/${Database.Database}"
      }
    }
  }
}