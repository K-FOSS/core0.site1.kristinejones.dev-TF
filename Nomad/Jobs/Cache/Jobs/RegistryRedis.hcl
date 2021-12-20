job "cache-registry-redis" {
  datacenters = ["core0site1"]

  group "registry-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "registry"
      port = "redis"

      task = "registry-redis-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]
    }

    task "registry-redis-server" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }
}

