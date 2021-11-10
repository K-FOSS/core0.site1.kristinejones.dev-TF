job "openproject-redis" {
  datacenters = ["core0site1"]

  group "openproject-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "openproject"
      port = "redis"

      task = "openproject-redis-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]
    }

    task "openproject-redis-server" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }
}

