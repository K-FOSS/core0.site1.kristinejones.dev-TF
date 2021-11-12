job "authentik-redis" {
  datacenters = ["core0site1"]

  group "authentik-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "authentik"
      port = "redis"

      task = "authentik-redis-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]
    }

    task "authentik-redis-server" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }
}

