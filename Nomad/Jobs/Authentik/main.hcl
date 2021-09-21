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
        AUTHENTIK_POSTGRESQL__HOST = "${Database.Hostname}"
        AUTHENTIK_POSTGRESQL__PORT = "${Database.Port}"

        AUTHENTIK_POSTGRESQL__NAME = "${Database.Database}"

        AUTHENTIK_POSTGRESQL__USER = "${Database.Username}"
        AUTHENTIK_POSTGRESQL__PASSWORD = "${Database.Password}"

        AUTHENTIK_SECRET_KEY = "${SECRET_KEY}"
      }

      template {
        data = <<EOH
# Lines starting with a # are ignored

# Empty lines are also ignored
AUTHENTIK_REDIS__HOST="{{ env "NOMAD_ADDR_redis_redis" }}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }

    task "authentik-server" {
      driver = "docker"

      config {
        image        = "ghcr.io/goauthentik/server"

        args = ["server"]

        ports = ["http"]
      }

      env = {
        #
        # Database
        #
        AUTHENTIK_POSTGRESQL__HOST = "${Database.Hostname}"
        AUTHENTIK_POSTGRESQL__PORT = "${Database.Port}"

        AUTHENTIK_POSTGRESQL__NAME = "${Database.Database}"

        AUTHENTIK_POSTGRESQL__USER = "${Database.Username}"
        AUTHENTIK_POSTGRESQL__PASSWORD = "${Database.Password}"

        AUTHENTIK_SECRET_KEY = "${SECRET_KEY}"
      }

      template {
        data = <<EOH
# Lines starting with a # are ignored

# Empty lines are also ignored
AUTHENTIK_REDIS__HOST="{{ env "NOMAD_ADDR_redis_redis" }}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }
}