job "nextcloud" {
  datacenters = ["core0site1"]

  group "nextcloud-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "nextcloud-redis"
      port = "redis"

      task = "redis"

      address_mode = "alloc"
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }

  group "nextcloud-server" {
    count = 1

    volume "${Volume.name}" {
      type      = "csi"
      read_only = false
      source    = "${Volume.name}"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "fpm" {
        to = 9000  
      }

      port "metrics" { }
    }

    service {
      name = "nextcloud-fastcgi-cont"
      port = "fpm"

      task = "nextcloud-server"

      address_mode = "alloc"
    }

    service {
      name = "nextcloud-web-cont"
      port = "http"

      task = "web"

      address_mode = "alloc"
    }

    task "web" {
      driver = "docker"

      volume_mount {
        volume      = "${Volume.name}"
        destination = "/var/www/html"
      }

      config {
        image        = "kristianfjones/caddy-core-docker:vps1"

        args = ["caddy", "run", "--config", "/local/caddyfile.json"]

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }

      template {
        data = <<EOF
${Caddyfile}
EOF

        destination = "local/caddyfile.json"
      }
    }

    task "nextcloud-worker" {
      driver = "docker"

      volume_mount {
        volume      = "${Volume.name}"
        destination = "/var/www/html"
      }

      config {
        image = "nextcloud:${Version}"

        command = "/cron.sh"

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }

      resources {
        cpu    = 1200
        memory = 600
      }
    
      env {
        HOUSEKEEPING_INTERVAL = "86400"
        METRICS_ENABLED = "true"

        #
        # Redis
        #
        REDIS_HOST = "nextcloud-redis.service.kjdev"
        REDIS_HOST_PORT = "6379"

        #
        # S3
        #
        OBJECTSTORE_S3_USEPATH_STYLE = "true"

        #
        # Reverse Proxy
        #
        NEXTCLOUD_TRUSTED_DOMAINS = "nextcloud.kristianjones.dev"
        TRUSTED_PROXIES = "0.0.0.0/0"
        OVERWRITEPROTOCOL = "https"
      }

      template {
        data = <<EOH
#
# PostgreSQL Databse
#
POSTGRES_HOST="${Database.Hostname}"
POSTGRES_DB="${Database.Database}"

POSTGRES_USER="${Database.Username}"
POSTGRES_PASSWORD="${Database.Password}"

#
# S3
#
OBJECTSTORE_S3_HOST="${S3.Connection.Hostname}"
OBJECTSTORE_S3_BUCKET="${S3.Bucket}"
OBJECTSTORE_S3_KEY="${S3.Credentials.AccessKey}"
OBJECTSTORE_S3_SECRET="${S3.Credentials.SecretKey}"
OBJECTSTORE_S3_PORT="${S3.Connection.Port}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }

    task "nextcloud-server" {
      driver = "docker"

      volume_mount {
        volume      = "${Volume.name}"
        destination = "/var/www/html"
      }

      config {
        image = "nextcloud:${Version}"

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }

      resources {
        cpu    = 1200
        memory = 600
      }
    
      env {
        HOUSEKEEPING_INTERVAL = "86400"
        METRICS_ENABLED = "true"

        #
        # Redis
        #
        REDIS_HOST = "nextcloud-redis.service.kjdev"
        REDIS_HOST_PORT = "6379"

        #
        # S3
        #
        OBJECTSTORE_S3_USEPATH_STYLE = "true"

        #
        # Reverse Proxy
        #
        NEXTCLOUD_TRUSTED_DOMAINS = "nextcloud.kristianjones.dev"
        TRUSTED_PROXIES = "0.0.0.0/0"
        OVERWRITEPROTOCOL = "https"
      }

      template {
        data = <<EOH
#
# PostgreSQL Databse
#
POSTGRES_HOST="${Database.Hostname}"
POSTGRES_DB="${Database.Database}"

POSTGRES_USER="${Database.Username}"
POSTGRES_PASSWORD="${Database.Password}"

#
# S3
#
OBJECTSTORE_S3_HOST="${S3.Connection.Hostname}"
OBJECTSTORE_S3_BUCKET="${S3.Bucket}"
OBJECTSTORE_S3_KEY="${S3.Credentials.AccessKey}"
OBJECTSTORE_S3_SECRET="${S3.Credentials.SecretKey}"
OBJECTSTORE_S3_PORT="${S3.Connection.Port}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }

    #
    # NextCloud Prometheus Exporter
    #
  }
}