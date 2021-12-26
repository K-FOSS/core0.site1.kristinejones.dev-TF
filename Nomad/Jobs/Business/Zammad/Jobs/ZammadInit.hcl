job "business-zammad-init" {
  datacenters = ["core0site1"]

  group "zammad-init" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }
    }

    service {
      name = "zammad"
      port = "https"

      task = "zammad-init"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.api"]
    }

    task "vikunja-api-server" {
      driver = "docker"

      config {
        image = "vikunja/api"

        entrypoint = ["/app/vikunja/vikunja"]

        args = ["web"]

        work_dir = "/local"
      }

      env {
        #
        # ElasticSearch
        #
        ELASTICSEARCH_ENABLED = "false"

        #
        # Redis
        #
        #REDIS_PASSWORD = ""
        REDIS_URL = "redis://redis.zammad.service.kjdev/0"

        #
        # Memcached
        #
        MEMCACHE_SERVERS = "memcached.zammad.service.kjdev"

        #MEMCACHED_HOST = ""

        #
        # Database
        #
        POSTGRESQL_HOST = "${Database.Hostname}"
        POSTGRESQL_PORT = "${Database.Port}"

        POSTGRESQL_DB = "${Database.Database}"

        POSTGRESQL_USER = "${Database.Username}"
        POSTGRESQL_PASS = "${Database.Password}"


        #
        # Rails
        #
        ZAMMAD_RAILSSERVER_HOST = "http.railsserver.zammad.service.kjdev"
        ZAMMAD_RAILSSERVER_PORT = "8080"

        #
        # WebSocket
        #
        ZAMMAD_WEBSOCKET_HOST = "http.websocket.zammad.service.dc1.kjdev"
        ZAMMAD_WEBSOCKET_PORT = "8080"


      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 128
      }
    }
  }
} 