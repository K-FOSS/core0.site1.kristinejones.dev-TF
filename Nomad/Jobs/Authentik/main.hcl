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

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
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
        image = "redis:alpine"

        network_mode = "bridge"

        hostname = "redis"
      }

      service {
        name = "authentik-redis-cont"
        port = "redis"

        address_mode = "driver"
      }
    }

    task "authentik-worker" {
      driver = "docker"

      config {
        image        = "ghcr.io/goauthentik/server"

        network_mode = "bridge"

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
AUTHENTIK_REDIS__HOST="authentik-redis-cont.service.kjdev"
EOH

        destination = "secrets/file.env"
        env         = true
      }

      resources {
        cpu    = 200
        memory = 300
      }
    }

    task "authentik-server" {
      driver = "docker"

      config {
        image        = "ghcr.io/goauthentik/server"

        network_mode = "bridge"

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
AUTHENTIK_REDIS__HOST="authentik-redis-cont.service.kjdev"
EOH

        destination = "secrets/file.env"
        env         = true
      }

      resources {
        cpu    = 200
        memory = 300
      }
    }
  }
}