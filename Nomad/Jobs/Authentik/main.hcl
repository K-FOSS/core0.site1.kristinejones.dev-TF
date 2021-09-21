job "authentik" {
  datacenters = ["core0site1"]

  group "auth-server" {
    count = 1

    network {
      mode = "bridge"

      port "http" { }

      port "redis" { 
        static = 6379
      }
    }

    service {
      name = "authentik-cont"
      port = "http"

      task = "authentik"

      connect {
        sidecar_service { }
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image        = "redis:alpine"

        ports = ["redis"]
      }
    }

    task "authentik-worker" {
      driver = "docker"

      config {
        image        = "ghcr.io/goauthentik/server"

        args = ["worker"]
      }

      env = {
        #
        # Database
        #
        AUTHENTIK_POSTGRESQL__HOST = "${Database.Host}"
        AUTHENTIK_POSTGRESQL__PORT = "${Database.Port}"

        AUTHENTIK_POSTGRESQL__NAME = "${Database.Database}"

        AUTHENTIK_POSTGRESQL__USER = "${Database.Username}"
        AUTHENTIK_POSTGRESQL__PASSWORD = "${Database.Password}"

        #
        # Cache
        #
        AUTHENTIK_REDIS__HOST = "NOMAD_ADDR_redis_redis"
      }
    }

    task "authentik-server" {
      driver = "docker"

      config {
        image        = "ghcr.io/goauthentik/server"

        ports = ["http"]
      }

      env = {
        #
        # Database
        #
        AUTHENTIK_POSTGRESQL__HOST = "${Database.Host}"
        AUTHENTIK_POSTGRESQL__PORT = "${Database.Port}"

        AUTHENTIK_POSTGRESQL__NAME = "${Database.Database}"

        AUTHENTIK_POSTGRESQL__USER = "${Database.Username}"
        AUTHENTIK_POSTGRESQL__PASSWORD = "${Database.Password}"

        #
        # Cache
        #
        AUTHENTIK_REDIS__HOST = "NOMAD_ADDR_redis_redis"
      }
    }
  }
}