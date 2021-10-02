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

    ephemeral_disk {
      size    = 500
      sticky  = true
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6-alpine"

        command = "redis-server"

        args = ["--requirepass", "${Redis.Password}"]

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
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

        ports = ["https"]
      
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
    
      env {
        HOUSEKEEPING_INTERVAL = "86400"
        METRICS_ENABLED = "true"

        #
        # Redis
        #
        REDIS_HOST = "nextcloud-redis.service.kjdev"

        #
        # S3
        #
        OBJECTSTORE_S3_USEPATH_STYLE = "true"
      }

      template {
        data = <<EOH
#
# Redis Cache
#
REDIS_HOST_PASSWORD="${Redis.Password}"

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
  }
}