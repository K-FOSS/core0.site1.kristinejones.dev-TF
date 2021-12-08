job "outline-redis" {
  datacenters = ["core0site1"]

  group "outline-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "outline"
      port = "redis"

      task = "outline-redis"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]
    }

    task "outline-redis" {
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

