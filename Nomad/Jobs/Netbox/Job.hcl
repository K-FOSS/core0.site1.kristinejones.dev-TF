job "netbox" {
  datacenters = ["core0site1"]

  group "netbox-redis" {
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
      name = "netbox-redis"
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

  group "netbox-cache" {
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
      name = "netbox-rediscache"
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

        args = ["--requirepass", "${RedisCache.Password}"]

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }
    }
  }

  group "netbox-worker" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    task "network-worker" {
      driver = "docker"

      user = "101"

      config {
        image = "netboxcommunity/netbox:${Version}"

        command = "/opt/netbox/venv/bin/python"

        args = ["/opt/netbox/netbox/manage.py", "rqworker"]

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
        # Redis Cache
        #
        REDIS_CACHE_DATABASE = "1"
        REDIS_CACHE_HOST = "netbox-rediscache.service.kjdev"
        REDIS_CACHE_SSL = "0"

        #
        # Redis
        #
        REDIS_DATABASE = "0"
        REDIS_HOST = "netbox-redis.service.kjdev"
        REDIS_SSL = "false"
      }

      template {
        data = <<EOH
# Lines starting with a # are ignored

# Empty lines are also ignored
AUTHENTIK_REDIS__HOST="authentik-redis-cont.service.kjdev"

#
# Redis Cache
#
REDIS_CACHE_PASSWORD="${RedisCache.Password}"

#
# Redis
#
REDIS_PASSWORD="${Redis.Password}"

#
# Misc
#
SECRET_KEY="${Netbox.SecretKey}"

#
# PostgreSQL Databse
#
DB_HOST="${Database.Hostname}"
DB_NAME="${Database.Database}"

DB_USER="${Database.Username}"
DB_PASSWORD="${Database.Password}"

SUPERUSER_EMAIL="${Netbox.AdminEmail}"
SUPERUSER_NAME="${Netbox.AdminUsername}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  
  }

  group "netbox-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080  
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "netbox-http-cont"
      port = "http"

      task = "netbox"

      address_mode = "alloc"
    }

    task "netbox" {
      driver = "docker"

      user = "101"

      config {
        image = "netboxcommunity/netbox:${Version}"

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
        # Redis Cache
        #
        REDIS_CACHE_DATABASE = "1"
        REDIS_CACHE_HOST = "netbox-rediscache.service.kjdev"
        REDIS_CACHE_SSL = "0"

        #
        # Redis
        #
        REDIS_DATABASE = "0"
        REDIS_HOST = "netbox-redis.service.kjdev"
        REDIS_SSL = "false"

        #
        # Auth
        #
        REMOTE_AUTH_ENABLED = "True"
        REMOTE_AUTH_HEADER = "HTTP_X_POMERIUM_CLAIM_PREFERRED_USERNAME"
        REMOTE_AUTH_DEFAULT_PERMISSIONS = "None"
        REMOTE_AUTH_AUTO_CREATE_USER = "True"
      }

      template {
        data = <<EOH
# Lines starting with a # are ignored

# Empty lines are also ignored
AUTHENTIK_REDIS__HOST="authentik-redis-cont.service.kjdev"

#
# Redis Cache
#
REDIS_CACHE_PASSWORD="${RedisCache.Password}"

#
# Redis
#
REDIS_PASSWORD="${Redis.Password}"

#
# Misc
#
SECRET_KEY="${Netbox.SecretKey}"

#
# PostgreSQL Databse
#
DB_HOST="${Database.Hostname}"
DB_NAME="${Database.Database}"

DB_USER="${Database.Username}"
DB_PASSWORD="${Database.Password}"

SUPERUSER_EMAIL="${Netbox.AdminEmail}"
SUPERUSER_NAME="${Netbox.AdminUsername}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }
}