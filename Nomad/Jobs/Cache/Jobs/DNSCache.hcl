job "dns-cache" {
  datacenters = ["core0site1"]

  group "dns-cache-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "dns"
      port = "redis"

      task = "github-redis-cache"
      address_mode = "alloc"

      tags = ["coredns.enabled", "cache.rns"]
    }

    task "rns-dns-redis-cache" {
      driver = "docker"

      config {
        image = "redis:latest"
      }

      resources {
        cpu = 64
        memory = 16
        memory_max = 32
      }
    }
  }
}

