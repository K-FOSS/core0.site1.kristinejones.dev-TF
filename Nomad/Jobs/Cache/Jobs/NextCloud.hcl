job "nextcloud-cache" {
  datacenters = ["core0site1"]

  group "nextcloud-cache-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "nextcloud-cache-redis"
      port = "redis"

      task = "nextcloud-redis-cache"
      address_mode = "alloc"

      tags = ["coredns.enabled"]
    }

    task "nextcloud-redis-cache" {
      driver = "docker"

      config {
        image = "redis:latest"
      }

      resources {
        cpu = 128
        memory = 32
        memory_max = 64
      }
    }
  }
}

