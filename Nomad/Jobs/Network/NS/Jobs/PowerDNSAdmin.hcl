job "network-ns-admin" {
  datacenters = ["core0site1"]

  group "powerdns-admin" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }
    }

    service {
      name = "powerdns"
      port = "http"

      task = "powerdns-admin-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "http.admin"]
    }

    task "powerdns-admin-server" {
      driver = "docker"

      config {
        image = "ngoduykhanh/powerdns-admin:latest"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=powerdns,service=admin"
          }
        }
      }

      env {
        #
        # Server
        #
        PORT = "8080"

        #
        # Gunicorn
        #
        GUNICORN_TIMEOUT = "60"
        GUNICORN_WORKERS = "2"

        GUNICORN_LOGLEVEL = "DEBUG"

        #
        # Misc
        #
        OFFLINE_MODE = "False"
      }

      #
      # Secrets
      #
      template {
        data = <<EOH
#
# Database
#
SQLA_DB_HOST="${PowerDNSAdmin.Database.Hostname}"
SQLA_DB_PORT="${PowerDNSAdmin.Database.Port}"

SQLA_DB_NAME="${PowerDNSAdmin.Database.Database}"

SQLA_DB_USER="${PowerDNSAdmin.Database.Username}"
SQLA_DB_PASSWORD="${PowerDNSAdmin.Database.Password}"

EOH

        destination = "secrets/file.env"
        env = true
      }
    }
  }
}