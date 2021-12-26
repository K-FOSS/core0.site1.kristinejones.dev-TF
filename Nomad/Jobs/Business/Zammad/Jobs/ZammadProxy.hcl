job "business-zammad-proxy" {
  datacenters = ["core0site1"]

  group "zammad-proxy" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }
    }

    task "wait-for-gitlab-webservice" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z https.webservice.gitlab.service.dc1.kjdev 443; do sleep 1; done"]
      }

      resources {
        cpu = 16
        memory = 16
      }
    }

    service {
      name = "zammad"
      port = "http"

      task = "zammad-proxy-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.proxy"]
    }

    task "zammad-proxy-server" {
      driver = "docker"

      config {
        image = "zammad/zammad-docker-compose:zammad-5.0.2-37"

        args = ["zammad-nginx"]
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

        #
        # Proxy
        #
        NGINX_SERVER_SCHEME = "https"
        NGINX_SERVER_NAME = "tickets.mylogin.space"
      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 128
      }
    }
  }
} 