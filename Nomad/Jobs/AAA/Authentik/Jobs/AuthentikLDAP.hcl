job "authentik-ldap" {
  datacenters = ["core0site1"]

  group "auth-ldap-server" {
    count = 4

    update {
      max_parallel = 1

      min_healthy_time = "45s"

      healthy_deadline = "3m"

      progress_deadline = "5m"
    }

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "metrics" { 
        to = 9300
      }

      port "ldap" { 
        to = 3389
      }

      port "ldaps" { 
        to = 6636
      }

      dns {
        servers = [
          "10.1.1.10",
          "10.1.1.13",
          "172.18.0.10"
        ]
      }
    }

    service {
      name = "authentik"
      port = "ldap"

      task = "authentik-ldap-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "ldap.ldap"]

      check {
        type = "tcp"
        port = "ldap"
        interval = "10s"
        timeout = "2s"
      }
    }

    service {
      name = "authentik"
      port = "ldaps"

      task = "authentik-ldap-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "ldaps.ldap"]

      check {
        type = "tcp"
        port = "ldaps"
        interval = "10s"
        timeout = "2s"
      }
    }

    service {
      name = "authentik"
      port = "metrics"

      task = "authentik-ldap-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "metrics.ldap"]
    }

    task "authentik-ldap-server" {
      driver = "docker"

      config {
        image = "goauthentik.io/ldap:${Version}"

        memory_hard_limit = 256

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=authentik,service=ldap"
          }
        }
      }

      env {
        AUTHENTIK_HOST = "${LDAP.AuthentikHost}"

        AUTHENTIK_INSECURE = "false"
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
# LDAP
#
AUTHENTIK_TOKEN="${LDAP.AuthentikToken}"
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