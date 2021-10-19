job "coturn" {
  datacenters = ["core0site1"]

  type = "service"

  group "coturn-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "coturn-redis-cont"
      port = "redis"

      task = "redis"

      address_mode = "alloc"
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:alpine"

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.dc1.kjdev:8080/loki/api/v1/push"
          }
        }
      }
    }
  }

  group "coturn" {
    count = 4

    spread {
      attribute = "$${node.unique.id}"
      weight    = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "turn" {
        to = 3478
      }

      port "stun" { }

      port "cli" { }
    }

    service {
      name = "coturn-turn-cont"
      port = "turn"

      task = "coturn-server"
      address_mode = "alloc"

      tags = ["coredns.enabled"]
    }

    service {
      name = "coturn-stun-cont"
      port = "stun"

      task = "coturn-server"
      address_mode = "alloc"

      tags = ["coredns.enabled"]
    }

    task "coturn-server" {
      driver = "docker"

      config {
        image = "coturn/coturn:edge-alpine"

        args = ["-c", "/local/turnserver.conf", "--prometheus"]

        ports = ["turn"]

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.dc1.kjdev:8080/loki/api/v1/push"
          }
        }
      }

      template {
        data = <<EOF
${CoTurn.Config}
EOF

        destination = "local/turnserver.conf"
      }
    }
  }
}