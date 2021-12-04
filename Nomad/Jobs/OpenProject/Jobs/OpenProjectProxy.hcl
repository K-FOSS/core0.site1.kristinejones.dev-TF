job "openproject-proxy" {
  datacenters = ["core0site1"]


  group "openproject-proxy" {

    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 80
      }
    }

    task "wait-for-opserver" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z https.server.openproject.service.dc1.kjdev 8080; do sleep 1; done"]
      }

      resources {
        cpu = 16
        memory = 16
      }
    }

    service {
      name = "openproject"
      port = "http"

      task = "openproject-proxy"

      address_mode = "alloc"

      tags = ["coredns.enabled", "proxy"]
    }

    task "openproject-proxy" {
      driver = "docker"

      config {
        image = "registry.kristianjones.dev/cache/openproject/community:${Version}"

        command = "./docker/prod/proxy"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=openproject,service=proxy"
          }
        }
      }

      env {
        #
        # Cache
        #
        RAILS_CACHE_STORE = "memcache"
        OPENPROJECT_CACHE__MEMCACHE__SERVER = "memcache.openproject.service.dc1.kjdev:11211"

        APP_HOST = "https.server.openproject.service.dc1.kjdev"

        OPENPROJECT_RAILS__RELATIVE__URL__ROOT = ""
        SERVER_NAME = "openproject.kristianjones.dev"

        #
        #
        #
        USE_PUMA = "true"

        #
        # Outbound Email
        #
        EMAIL_DELIVERY_METHOD = "smtp"
        SMTP_ADDRESS = "${SMTP.Server}"
        SMTP_PORT = "${SMTP.Port}"

        SMTP_DOMAIN = "kristianjones.dev"
        SMTP_AUTHENTICATION = "login"
        SMTP_ENABLE_STARTTLS_AUTO = "true"
      }

      template {
        data = <<EOH
#
# Database
#
DATABASE_URL="postgres://${Database.Username}:${Database.Password}@${Database.Hostname}:${Database.Port}/${Database.Database}?pool=20&encoding=unicode&reconnect=true"

#
# Storage
#
OPENPROJECT_FOG_CREDENTIALS_AWS__ACCESS__KEY__ID="${S3.Credentials.AccessKey}"
OPENPROJECT_FOG_CREDENTIALS_AWS__SECRET__ACCESS__KEY="${S3.Credentials.SecretKey}"

#
# Email
#

SMTP_USER_NAME="${SMTP.Username}"
SMTP_PASSWORD="${SMTP.Password}"
EOH

        destination = "secrets/file.env"
        env = true
      }
    }
  }
}