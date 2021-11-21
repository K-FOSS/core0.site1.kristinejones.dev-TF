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
      name = "coturn"
      port = "turn"

      task = "coturn-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "turn"]
    }

    service {
      name = "coturn"
      port = "stun"

      task = "coturn-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "stun"]
    }

    task "coturn-server" {
      driver = "docker"

      config {
        image = "coturn/coturn:edge-alpine"

        args = ["-c", "/local/turnserver.conf", "--prometheus"]

        memory_hard_limit = 256
      }

      template {
        data = <<EOF
${CoTurn.Config}
EOF

        destination = "local/turnserver.conf"
      }

      resources {
        cpu = 128
        memory = 256
        memory_max = 256
      }
    }
  }
}