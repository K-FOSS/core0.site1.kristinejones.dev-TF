job "cache-threatmapper-redis" {
  datacenters = ["core0site1"]

  group "threatmapper-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "threatmapper"
      port = "redis"

      task = "threatmapper-redis-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]
    }

    task "threatmapper-redis-server" {
      driver = "docker"

      config {
        image = "deepfenceio/deepfence_redis_ce:latest"
      }

      env {
        INITIALIZE_REDIS = "Y"
      }

      resources {
        cpu = 128
        memory = 32
        memory_max = 64
      }
    }
  }
}

