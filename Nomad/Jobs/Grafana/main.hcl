job "grafana" {
  datacenters = ["core0site1"]

  group "grafana" {
    count = 1

    network {
      mode = "bridge"

      port "http" { }

      port "redis" {
        static = 6379
      }
    }

    service {
      name = "grafana-cont"
      port = "http"

      task = "grafana-web"

      connect {
        sidecar_service {}
      }
    }
    
    task "grafana-redis" {
      driver = "docker"

      config {
        image = "redis:6.2.5"

        ports = ["redis"]
      }
    }

    task "grafana-web" {
      driver = "docker"

      config {
        image = "grafana/grafana:8.0.3"

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