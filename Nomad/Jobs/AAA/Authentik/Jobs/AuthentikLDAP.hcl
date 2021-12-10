job "authentik-ldap" {
  datacenters = ["core0site1"]

  group "auth-ldap-server" {
    count = 3

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

      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "authentik"
      port = "ldap"

      task = "authentik-ldap-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "ldap.ldap"]
    }

    service {
      name = "authentik"
      port = "metrics"

      task = "authentik-ldap-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics.ldap"]
    }

    task "authentik-ldap-server" {
      driver = "docker"

      config {
        image = "goauthentik.io/ldap:${Version}"
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
        env         = true
      }

      resources {
        cpu = 200

        memory = 800
      }
    }
  }
}