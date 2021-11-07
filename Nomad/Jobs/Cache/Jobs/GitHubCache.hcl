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
    }

    task "github-redis-cache" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }

  group "github-cache-server" {
    count = 3

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

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=cache,service=github"
          }
        }
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

