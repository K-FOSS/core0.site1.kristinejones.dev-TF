job "authentik-server" {
  datacenters = ["core0site1"]

  group "auth-server" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    update {
      max_parallel = 1

      health_check = "checks"
      
      min_healthy_time = "30s"

      healthy_deadline = "3m"

      progress_deadline = "8m"
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
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "authentik"
      port = "metrics"

      task = "authentik-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "metrics.server"]

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
          limit = 12
          grace = "60s"
          ignore_warnings = false
        }
      }
    }

    service {
      name = "authentik"
      port = "http"

      task = "authentik-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.server"]

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
          limit = 12
          grace = "60s"
          ignore_warnings = false
        }
      }
    }

    task "authentik-server" {
      driver = "docker"

      config {
        image = "${Authentik.Image.Repo}/server:${Authentik.Image.Tag}"

        args = ["server"]

        memory_hard_limit = 1024

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=authentik,service=server"
          }
        }
      }

      resources {
        cpu = 256

        memory = 512
        memory_max = 1024
      }

      env {
        #
        # Database
        #
        AUTHENTIK_POSTGRESQL__HOST = "${Authentik.Database.Hostname}"
        AUTHENTIK_POSTGRESQL__PORT = "${Authentik.Database.Port}"

        AUTHENTIK_COOKIE_DOMAIN = "mylogin.space"

        AUTHENTIK_EMAIL__USE_TLS = "true"

        #
        # Backups
        #
        AUTHENTIK_POSTGRESQL__S3_BACKUP__REGION = "us-east-1"
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
AUTHENTIK_POSTGRESQL__NAME="${Authentik.Database.Database}"

# Database Credentials
AUTHENTIK_POSTGRESQL__USER="${Authentik.Database.Username}"
AUTHENTIK_POSTGRESQL__PASSWORD="${Authentik.Database.Password}"

#
# Secrets
#
AUTHENTIK_SECRET_KEY="${Authentik.Secrets.SecretKey}"

#
# Email
#
AUTHENTIK_EMAIL__HOST="${Authentik.SMTP.Server}"
AUTHENTIK_EMAIL__PORT="${Authentik.SMTP.Port}"

AUTHENTIK_EMAIL__FROM="${SMTP.Username}"
AUTHENTIK_EMAIL__USERNAME="${Authentik.SMTP.Username}"
AUTHENTIK_EMAIL__PASSWORD="${Authentik.SMTP.Password}"

#
# Backups
#
AUTHENTIK_POSTGRESQL__S3_BACKUP__BUCKET="${Authentik.S3.Bucket}"
AUTHENTIK_POSTGRESQL__S3_BACKUP__HOST="http://${Authentik.S3.Connection.Endpoint}"
AUTHENTIK_POSTGRESQL__S3_BACKUP__INSECURE_SKIP_VERIFY="true"
AUTHENTIK_POSTGRESQL__S3_BACKUP__ACCESS_KEY="${Authentik.S3.Credentials.AccessKey}"
AUTHENTIK_POSTGRESQL__S3_BACKUP__SECRET_KEY="${Authentik.S3.Credentials.SecretKey}"
EOH

        destination = "secrets/file.env"
        env = true
      }
    }
  }
}