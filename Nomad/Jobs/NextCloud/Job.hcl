job "nextcloud" {
  datacenters = ["core0site1"]

  group "nextcloud-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
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

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080  
      }

      port "fpm" {
        to = 9000  
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
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
REDIS_HOST_PASSWORD="${RedisCache.Password}"

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