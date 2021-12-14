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
        to = 80
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
        PORT = "80"

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

        PDNS_PROTO = "http"
        PDNS_PORT = "8080"
        PDNS_HOST = "http.api.powerdns.service.kjdev"
        PDNS_API_KEY = "${PowerDNS.APIKey}"
      }

      #
      # Secrets
      #
      template {
        data = <<EOH
SQLALCHEMY_DATABASE_URI="postgresql://${PowerDNSAdmin.Database.Username}:${PowerDNSAdmin.Database.Password}@${PowerDNSAdmin.Database.Hostname}:${PowerDNSAdmin.Database.Port}/${PowerDNSAdmin.Database.Database}"
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