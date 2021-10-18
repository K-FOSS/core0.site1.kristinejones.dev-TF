job "authentik" {
  datacenters = ["core0site1"]

  group "authentik-cache" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
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

  }

  group "auth-workers" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight    = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 9000
      }

      port "metrics" { 
        to = 9300
      }
    }

    service {
      name = "authentik-worker"
      port = "http"

      task = "authentik-worker"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      #
      # Liveness check
      #
      check {
        name = "HTTP Check"
        type = "http"

        address_mode = "alloc"
        port = "http"

        path = "/-/health/live/"
        interval = "10s"
        timeout  = "3s"

        check_restart {
          limit = 6
          grace = "60s"
          ignore_warnings = true
        }
      }
    }

    service {
      name = "authentik-worker"
      port = "metrics"

      task = "authentik-worker"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      #
      # Liveness check
      #
      check {
        name = "HTTP Check"
        type = "http"

        address_mode = "alloc"
        port = "http"

        path = "/-/health/live/"
        interval = "10s"
        timeout  = "3s"

        check_restart {
          limit = 6
          grace = "60s"
          ignore_warnings = true
        }
      }
    }

    task "authentik-worker" {
      driver = "docker"

      config {
        image = "ghcr.io/goauthentik/server:${Version}"

        args = ["worker"]
      }

      env {
        #
        # Database
        #
        AUTHENTIK_POSTGRESQL__HOST = "${Database.Hostname}"
        AUTHENTIK_POSTGRESQL__PORT = "${Database.Port}"
      }

      template {
        data = <<EOH
#
# Cache
#
AUTHENTIK_REDIS__HOST="authentik-redis-cont.service.dc1.kjdev"

#
# Database
#
AUTHENTIK_POSTGRESQL__NAME="${Database.Database}"

# Database Credentials
AUTHENTIK_POSTGRESQL__USER="${Database.Username}"
AUTHENTIK_POSTGRESQL__PASSWORD="${Database.Password}"

#
# Secrets
#
AUTHENTIK_SECRET_KEY="${Authentik.SecretKey}"
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

  group "auth-server" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 9000
      }

      port "metrics" { 
        to = 9300
      }
    }

    service {
      name = "authentik-cont"
      port = "metrics"

      task = "authentik-server"
      address_mode = "alloc"

      #
      # Liveness check
      #
      check {
        name = "HTTP Check"
        type = "http"

        address_mode = "alloc"
        port = "http"

        path     = "/-/health/live/"
        interval = "10s"
        timeout  = "3s"

        check_restart {
          limit = 6
          grace = "60s"
          ignore_warnings = true
        }
      }
    }

    service {
      name = "authentik-cont"
      port = "http"

      task = "authentik-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      #
      # Liveness check
      #
      check {
        name = "HTTP Check"
        type = "http"

        address_mode = "alloc"
        port = "http"

        path = "/-/health/live/"
        interval = "10s"
        timeout  = "3s"

        check_restart {
          limit = 6
          grace = "60s"
          ignore_warnings = true
        }
      }

      #
      # Readyness
      #
      check {
        name = "HTTP Check"
        type = "http"

        address_mode = "alloc"
        port = "http"

        path = "/-/health/ready/"
        interval = "10s"
        timeout = "3s"

        #
        # Failures
        #
        failures_before_critical = 6

        check_restart {
          limit = 6
          grace = "60s"
          ignore_warnings = true
        }
      }
    }

    task "authentik-server" {
      driver = "docker"

      config {
        image = "ghcr.io/goauthentik/server:${Version}"

        args = ["server"]
      }

      env {
        #
        # Database
        #
        AUTHENTIK_POSTGRESQL__HOST = "${Database.Hostname}"
        AUTHENTIK_POSTGRESQL__PORT = "${Database.Port}"
      }

      template {
        data = <<EOH
#
# Cache
#
AUTHENTIK_REDIS__HOST="authentik-redis-cont.service.dc1.kjdev"

#
# Database
#
AUTHENTIK_POSTGRESQL__NAME="${Database.Database}"

# Database Credentials
AUTHENTIK_POSTGRESQL__USER="${Database.Username}"
AUTHENTIK_POSTGRESQL__PASSWORD="${Database.Password}"

#
# Secrets
#
AUTHENTIK_SECRET_KEY="${Authentik.SecretKey}"
EOH

        destination = "secrets/file.env"
        env         = true
      }

      resources {
        cpu = 800
        memory = 500
      }
    }
  }
}