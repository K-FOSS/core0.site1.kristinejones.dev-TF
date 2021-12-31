job "netbox" {
  datacenters = ["core0site1"]

  group "netbox-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "netbox-redis"
      port = "redis"

      task = "redis"
      address_mode = "alloc"

      tags = ["coredns.enabled"]
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6-alpine"

        command = "redis-server"

        args = ["--requirepass", "${Redis.Password}"]
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
    }

    service {
      name = "netbox-rediscache"
      port = "redis"

      task = "redis"
      address_mode = "alloc"

      tags = ["coredns.enabled"]
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6-alpine"

        command = "redis-server"

        args = ["--requirepass", "${RedisCache.Password}"]
      }
    }
  }

  group "netbox-worker" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    task "netbox-worker" {
      driver = "docker"

      user = "1000"

      config {
        image = "netboxcommunity/netbox:${Version}"

        command = "/opt/netbox/venv/bin/python"
        args = ["/opt/netbox/netbox/manage.py", "rqworker"]

        memory_hard_limit = 256
      }

      env {
        #
        # Misc
        #
        SKIP_STARTUP_SCRIPTS = "True"

        HOUSEKEEPING_INTERVAL = "86400"
        METRICS_ENABLED = "true"

        #
        # Redis Cache
        #
        REDIS_CACHE_DATABASE = "1"
        REDIS_CACHE_HOST = "netbox-rediscache.service.kjdev"
        REDIS_CACHE_SSL = "0"

        #
        # Misc
        #
        ALLOWED_HOSTS = "netbox.int.mylogin.space netbox-http-cont.service.kjdev"
        TIME_ZONE = "America/Winnipeg"

        #
        # Redis
        #
        REDIS_DATABASE = "0"
        REDIS_HOST = "netbox-redis.service.kjdev"
        REDIS_SSL = "false"
      }

      template {
        data = <<EOH
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
DB_PORT="${Database.Port}"

DB_USER="${Database.Username}"
DB_PASSWORD="${Database.Password}"

SUPERUSER_EMAIL="${Netbox.AdminEmail}"
SUPERUSER_NAME="${Netbox.AdminUsername}"
EOH

        destination = "secrets/file.env"
        env         = true
      }

      resources {
        cpu = 128

        memory = 64
        memory_max = 256
      }
    }
  
  }

  group "netbox-server" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080  
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
      name = "netbox-http-cont"
      port = "http"

      task = "netbox"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled"]
    }

    task "netbox" {
      driver = "docker"

      user = "1000"

      config {
        image = "netboxcommunity/netbox:${Version}"

        memory_hard_limit = 256
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
        # Misc
        #
        ALLOWED_HOSTS = "netbox.int.mylogin.space netbox-http-cont.service.kjdev netbox-http-cont.service.dc1.kjdev"
        TIME_ZONE = "America/Winnipeg"

        #
        # Auth
        #
        REMOTE_AUTH_ENABLED = "True"
        REMOTE_AUTH_HEADER = "HTTP_X_POMERIUM_CLAIM_NICKNAME"
        REMOTE_AUTH_DEFAULT_PERMISSIONS = "None"
        REMOTE_AUTH_AUTO_CREATE_USER = "True"
      }

      template {
        data = <<EOH
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
DB_PORT="${Database.Port}"

DB_USER="${Database.Username}"
DB_PASSWORD="${Database.Password}"

SUPERUSER_EMAIL="${Netbox.AdminEmail}"
SUPERUSER_NAME="${Netbox.AdminUsername}"
EOH

        destination = "secrets/file.env"
        env = true
      }

      resources {
        cpu = 64

        memory = 32
        memory_max = 256
      }
    }
  }
}