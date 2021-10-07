job "bitwarden" {
  datacenters = ["core0site1"]

  group "bitwarden" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { }

      port "ws" {
        to = 3012
      }
    }

    service {
      name = "bitwarden-cont"
      port = "http"

      task = "vault"

      address_mode = "alloc"
    }

    service {
      name = "bitwarden-ws-cont"
      port = "ws"

      task = "vault"

      address_mode = "alloc"
    }

    task "vault" {
      driver = "docker"

      config {
        image = "vaultwarden/server:alpine"
      }

      env {
        WEBSOCKET_ENABLED = "true"
        ROCKET_PORT = "$${NOMAD_PORT_http}"
        DATABASE_URL = "postgresql://${Database.Username}:${Database.Password}@${Database.Hostname}:5432/${Database.Database}"
      }
    }
  }
}