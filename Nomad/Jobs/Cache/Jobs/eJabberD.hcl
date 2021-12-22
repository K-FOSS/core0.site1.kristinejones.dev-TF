job "cache-ejabberd" {
  datacenters = ["core0site1"]

  group "ejabberd-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "ejabberd"
      port = "redis"

      task = "ejabberd-redis-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]
    }

    task "ejabberd-redis-server" {
      driver = "docker"

      config {
        image = "redis:6-alpine3.14"
        
        command = "redis-server"

        args = ["/local/redis.conf"]
      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 128
      }

      template {
        data = <<EOF
port 6379

requirepass "${Redis.Password}"
EOF

        destination = "local/redis.conf"
      }
    }
  }
}

