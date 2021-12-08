job "business-outline-api" {
  datacenters = ["core0site1"]

  group "outline-api" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 8080
      }
    }

    service {
      name = "outline"
      port = "https"

      task = "outline-api-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.api"]
    }

    task "outline-api-server" {
      driver = "docker"

      config {
        image = "outlinewiki/outline:${Outline.Version}"
      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 128
      }

      env {


        #
        # Network
        #
        URL = "notes.kristianjones.dev"
        PORT = "8080"


        #
        # AAA
        #
        OIDC_SCOPES = "openid email profile"
        OIDC_DISPLAY_NAME = "Authentik"
        OIDC_USERNAME_CLAIM = "preferred_username"


        #
        # TODO: Urgent Get OpenID App/Provider and configure
        #
        OIDC_AUTH_URI = "https://auth.kristianjones.dev/application/o/authorize/"
        OIDC_TOKEN_URI = "https://auth.kristianjones.dev/application/o/token/"
        OIDC_USERINFO_URI = "https://auth.kristianjones.dev/application/o/userinfo/"

        #
        # Storage
        #
        AWS_S3_FORCE_PATH_STYLE = "true"
        # TODO: Learn about this
        AWS_S3_ACL = "private"

        #
        # Misc
        #
        # TODO
        #
        COLLABORATION_URL = ""


        #
        # Region
        #
        DEFAULT_LANGUAGE = "en_US"





      }


      template {
        data = <<EOH
#
# Database
#
DATABASE_URL="postgres://${Outline.Database.Username}:${Outline.Database.Password}@${Outline.Database.Hostname}:${Outline.Database.Port}/${Outline.Database.Database}?pool=20&encoding=unicode&reconnect=true"

#
# Redis
#
REDIS_URL="redis://redis.outline.service.kjdev:6379"

#
# Secrets
#
SECRET_KEY="${Outline.Secrets.SecretKey}"
UTILS_SECRET="${Outline.Secrets.UtilsSecretKey}"

#
# AAA
#

#
# OpenID
#
OIDC_CLIENT_ID="${Outline.OpenID.ClientID}"
OIDC_CLIENT_SECRET="${Outline.OpenID.ClientSecret}"

#
# Storage
#

#
# S3
#
# TODO: S3
# 
AWS_S3_UPLOAD_BUCKET_URL="${Outline.S3.Connection.Endpoint}"
AWS_ACCESS_KEY_ID="${Outline.S3.Credentials.AccessKey}"
AWS_SECRET_ACCESS_KEY="${Outline.S3.Credentials.SecretKey}"
EOH

        destination = "secrets/file.env"
        env = true
      }
    }
  }
}