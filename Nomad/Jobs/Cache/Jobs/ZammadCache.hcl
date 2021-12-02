job "cache-zammad" {
  datacenters = ["core0site1"]

  group "zammad-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "zammad"
      port = "redis"

      task = "zammad-redis-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]
    }

    task "zammad-redis-server" {
      driver = "docker"

      config {
        image = "redis:latest"
      }

      template {
        data = <<EOF
port 6379

AUTH redispass
EOF

        destination = "local/redis.conf"
      }
    }
  }

  group "zammad-memcached" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "memcache" { 
        to = 11211
      }
    }

    service {
      name = "zammad"
      port = "memcache"

      task = "zammad-memcache-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "memcache"]
    }

    task "zammad-memcache-server" {
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

