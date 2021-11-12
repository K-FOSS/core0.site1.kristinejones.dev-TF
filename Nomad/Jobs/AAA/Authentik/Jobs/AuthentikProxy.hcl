job "authentik-proxy" {
  datacenters = ["core0site1"]

  group "auth-proxy-server" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 9000
      }

      port "metrics" { 
        to = 9300
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
      port = "http"

      task = "authentik-proxy-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.proxy"]

      meta {
        meta = "for your service"
      }
    }

    service {
      name = "authentik"
      port = "metrics"

      task = "authentik-proxy-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics.proxy"]
    }

    task "authentik-proxy-server" {
      driver = "docker"

      config {
        image = "goauthentik.io/proxy::${Version}"

        args = ["worker"]
      }

      env {
        AUTHENTIK_HOST = "http://http.server.authentik.service.dc1.kjdev:9000"

        AUTHENTIK_INSECURE = "true"
      }

      template {
        data = <<EOH
#
# Cache
#
AUTHENTIK_REDIS__HOST="redis.authentik-.service.dc1.kjdev"

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