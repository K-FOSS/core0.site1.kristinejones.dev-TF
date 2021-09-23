job "coturn" {
  datacenters = ["core0site1"]

  group "coturn" {
    count = 4

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    network {
      mode = "bridge"

      port "stun" { }

      port "turn" { }

      port "metrics" {
        static = 9641
      }

      port "cli" { }
    }

    service {
      name = "coturn-stun-cont"
      port = "stun"

      task = "coturn-server"

      connect {
        sidecar_service {}
      }
    }

    service {
      name = "coturn-turn-cont"
      port = "turn"

      task = "coturn-server"

      connect {
        sidecar_service {}
      }
    }

    service {
      name = "coturn-metrics-cont"
      port = "metrics"

      task = "coturn-server"

      connect {
        sidecar_service {}
      }
    }

    service {
      name = "coturn-cli-cont"
      port = "cli"

      task = "coturn-server"

      connect {
        sidecar_service {}
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:alpine"

        network_mode = "bridge"

        hostname = "redis"
      }

      service {
        name = "coturn-redis-cont"
        port = "redis"

        address_mode = "driver"
      }
    }

    task "coturn-server" {
      driver = "docker"

      config {
        image = "coturn/coturn:edge-alpine"

        args = ["-c=/local/turnserver.conf", "--prometheus"]
      }

      template {
        data = <<EOF
${CONFIG}
EOF

        destination = "local/turnserver.conf"
      }
    }
  }
}