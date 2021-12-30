job "authentik-worker" {
  datacenters = ["core0site1"]

  group "auth-workers" {
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

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    service {
      name = "authentik"
      port = "http"

      task = "authentik-worker"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.worker"]

      meta {
        meta = "for your service"
      }
    }

    service {
      name = "authentik"
      port = "metrics"

      task = "authentik-worker"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics.worker"]
    }

    task "authentik-worker" {
      driver = "docker"

      config {
        image = "ghcr.io/goauthentik/server:${Version}"

        args = ["worker"]

        memory_hard_limit = 1024

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=authentik,service=worker"
          }
        }
      }

      env {
        #
        # Database
        #
        AUTHENTIK_POSTGRESQL__HOST = "${Database.Hostname}"
        AUTHENTIK_POSTGRESQL__PORT = "${Database.Port}"

        AUTHENTIK_EMAIL__USE_TLS = "true"
      }

      template {
        data = <<EOH
#
# Cache
#
AUTHENTIK_REDIS__HOST="redis.authentik.service.dc1.kjdev"

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

#
# Email
#
AUTHENTIK_EMAIL__HOST="${SMTP.Server}"
AUTHENTIK_EMAIL__PORT="${SMTP.Port}"

AUTHENTIK_EMAIL__FROM="${SMTP.Username}"
AUTHENTIK_EMAIL__USERNAME="${SMTP.Username}"
AUTHENTIK_EMAIL__PASSWORD="${SMTP.Password}"
EOH

        destination = "secrets/file.env"
        env = true
      }

      resources {
        cpu = 128

        memory = 256
        memory_max = 1024
      }
    }
  }
}