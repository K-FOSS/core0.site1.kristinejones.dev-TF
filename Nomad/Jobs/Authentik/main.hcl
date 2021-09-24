job "authentik" {
  datacenters = ["core0site1"]

  group "auth-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        static = 9000
      }

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

      address_mode = "alloc"
    }

    service {
      name = "authentik-redis-cont"
      port = "redis"

      task = "redis"

      address_mode = "alloc"
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:alpine"
      }


    }

    task "authentik-worker" {
      driver = "docker"

      config {
        image        = "ghcr.io/goauthentik/server"

        args = ["worker"]
      }

      env {
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
        cpu    = 800
        memory = 500
      }
    }

    task "authentik-server" {
      driver = "docker"

      config {
        image        = "ghcr.io/goauthentik/server"

        args = ["server"]
      }

      env {
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
        cpu    = 800
        memory = 500
      }
    }
  }
}