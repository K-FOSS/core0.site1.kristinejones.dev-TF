job "business-zammad-scheduler" {
  datacenters = ["core0site1"]

  group "zammad-scheduler" {
    count = 1

    network {
      mode = "cni/nomadcore1"
    }

    task "vikunja-scheduler-server" {
      driver = "docker"

      config {
        image = "zammad/zammad-docker-compose:zammad-5.0.2-37"

        args = ["zammad-scheduler"]
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

        #
        # Database
        #
        POSTGRESQL_HOST = "${Database.Hostname}"
        POSTGRESQL_PORT = "${Database.Port}"

        POSTGRESQL_DB = "${Database.Database}"

        POSTGRESQL_USER = "${Database.Username}"
        POSTGRESQL_PASS = "${Database.Password}"

        POSTGRESQL_DB_CREATE = "true"


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