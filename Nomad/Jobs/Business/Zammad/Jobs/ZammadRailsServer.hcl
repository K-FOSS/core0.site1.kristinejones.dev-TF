job "business-zammad-railsserver" {
  datacenters = ["core0site1"]

  group "zammad-railsserver" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }
    }

    service {
      name = "zammad"
      port = "http"

      task = "vikunja-rails-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.railsserver"]
    }

    task "vikunja-rails-server" {
      driver = "docker"

      config {
        image = "zammad/zammad-docker-compose:zammad-5.0.2-37"

        args = ["zammad-railsserver"]
      }

      env {
        #
        # ElasticSearch
        #
        ELASTICSEARCH_ENABLED = "false"

        #
        # Redis
        #
        REDIS_PASSWORD = ""
        REDIS_URL = ""

        #
        # Memcached
        #
        MEMCACHE_SERVERS = ""

        MEMCACHED_HOST = ""

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
        ZAMMAD_RAILSSERVER_HOST = "http.railserver.zammad.service.kjdev"
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