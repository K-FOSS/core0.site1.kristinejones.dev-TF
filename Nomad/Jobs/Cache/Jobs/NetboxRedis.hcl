job "cache-netbox-redis" {
  datacenters = ["core0site1"]

  group "netbox-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "netbox"
      port = "redis"

      task = "redis"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6-alpine"

        command = "redis-server"

        args = ["--requirepass", "${Redis.General.Password}"]
      }
    }
  }

  group "netbox-cache" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "netbox"
      port = "redis"

      task = "redis"
      address_mode = "alloc"

      tags = ["coredns.enabled", "cache"]
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6-alpine"

        command = "redis-server"

        args = ["--requirepass", "${Redis.Cache.Password}"]
      }
    }
  }
}