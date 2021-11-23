job "cache-openproject" {
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

  group "openproject-memcached" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "memcache" { 
        to = 11211
      }
    }

    service {
      name = "openproject"
      port = "memcache"

      task = "openproject-memcache-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "memcache"]
    }

    task "openproject-memcache-server" {
      driver = "docker"

      config {
        image = "memcached:1.6"
      }

      resources {
        cpu = 128
        memory = 256
        memory_max = 256
      }
    }
  }
}

