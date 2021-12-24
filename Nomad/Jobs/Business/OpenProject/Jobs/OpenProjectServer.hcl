job "openproject-server" {
  datacenters = ["core0site1"]

  group "openproject-server" {
    count = 3

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 80
      }
    }

    task "wait-for-cache" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z memcache.openproject.service.dc1.kjdev 11211; do sleep 1; done"]
      }

      resources {
        cpu = 16
        memory = 16
      }
    }

    service {
      name = "openproject"
      port = "https"

      task = "openproject-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https.server"]
    }

    task "openproject-server" {
      driver = "docker"

      config {
        image = "registry.kristianjones.dev/cache/openproject/community:${Version}"

        args = ["./docker/prod/web"]

        memory_hard_limit = 1024

        mount {
          type = "tmpfs"
          target = "/app/tmp"
          readonly = false
          tmpfs_options = {
            size = 100000
          }
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=openproject,service=server"
          }
        }
      }

      resources {
        cpu = 256

        memory = 256
        memory_max = 1024
      }
    
      env {
        #
        # Cache
        #
        RAILS_CACHE_STORE = "memcache"
        OPENPROJECT_CACHE__MEMCACHE__SERVER = "memcache.openproject.service.dc1.kjdev:11211"

        #
        # Storage
        #
        # Docs: https://www.openproject.org/docs/installation-and-operations/installation/docker/
        #
        OPENPROJECT_ATTACHMENTS__STORAGE = "fog"
        OPENPROJECT_FOG_CREDENTIALS_ENDPOINT = "http://${S3.Connection.Endpoint}"
        
        OPENPROJECT_FOG_DIRECTORY = "${S3.Bucket}"
        OPENPROJECT_FOG_CREDENTIALS_PROVIDER = "aws"
        OPENPROJECT_FOG_CREDENTIALS_PATH__STYLE = "true"

        OPENPROJECT_RAILS__RELATIVE__URL__ROOT = ""

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

        #
        # Auth
        #
        OPENPROJECT_OPENID__CONNECT_KEYCLOAK_ISSUER = "https://mylogin.space/application/o/OpenProject/"
        OPENPROJECT_OPENID__CONNECT_KEYCLOAK_SCOPE = "openid email profile"

        OPENPROJECT_OPENID__CONNECT_KEYCLOAK_TOKEN__ENDPOINT = "https://mylogin.space/application/o/token/"
        OPENPROJECT_OPENID__CONNECT_KEYCLOAK_USERINFO__ENDPOINT = "https://mylogin.space/application/o/userinfo/"
        OPENPROJECT_OPENID__CONNECT_KEYCLOAK_AUTHORIZATION__ENDPOINT = "https://mylogin.space/application/o/authorize/"

        
        
        OPENPROJECT_OPENID__CONNECT_KEYCLOAK_SSO = "true"
        OPENPROJECT_OPENID__CONNECT_KEYCLOAK_DISCOVERY = "true"

        OPENPROJECT_OPENID__CONNECT_KEYCLOAK_DISPLAY__NAME = "KJDev"
        OPENPROJECT_OPENID__CONNECT_KEYCLOAK_HOST = "mylogin.space"
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

#
# OpenID
#
OPENPROJECT_OPENID__CONNECT_KEYCLOAK_IDENTIFIER="${OpenID.ClientID}"
OPENPROJECT_OPENID__CONNECT_KEYCLOAK_SECRET="${OpenID.ClientSecret}"
EOH

        destination = "secrets/file.env"
        env = true
      }
    }
  }
}