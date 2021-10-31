job "cache" {
  datacenters = ["core0site1"]

  group "github-cache-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "github-cache-redis"
      port = "redis"

      task = "github-redis-cache"
      address_mode = "alloc"

      tags = ["coredns.enabled"]

      check {
        name = "tcp_validate"

        type = "tcp"

        port = "redis"
        address_mode = "alloc"

        initial_status = "passing"

        interval = "30s"
        timeout  = "10s"

        check_restart {
          limit = 6
          grace = "120s"
          ignore_warnings = true
        }
      }
    }

    task "github-redis-cache" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }

  group "cache-web" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }
    }

    service {
      name = "github-cache-web-cont"
      port = "http"

      task = "web"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled"]
    }

    task "web" {
      driver = "docker"

      config {
        image = "kristianfjones/caddy-core-docker:vps1"

        args = ["caddy", "run", "--config", "/local/caddyfile.json"]
      }

      template {
        data = <<EOF
${Caddyfile}
EOF

        destination = "local/caddyfile.json"
      }
    }
  }


  group "github-cache-server" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }
    }

    service {
      name = "github-cache-server"
      port = "http"

      task = "github-cache-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "http"]
    }

    task "github-cache-server" {
      driver = "docker"

      config {
        image = "quay.io/app-sre/github-mirror"
      }

      env {
        CACHE_TYPE = "redis"

        #
        # Redis Cache
        #
        PRIMARY_ENDPOINT = "github-cache-redis.service.dc1.kjdev"

        REDIS_PORT = "6379"
      }
    }
  }
}

