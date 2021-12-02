job "cache-vikunja" {
  datacenters = ["core0site1"]

  group "vikunja-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "vikunja"
      port = "redis"

      task = "vikunja-redis-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]
    }

    task "vikunja-redis-server" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }
}

