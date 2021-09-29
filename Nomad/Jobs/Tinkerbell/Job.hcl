job "tinkerbell" {
  datacenters = ["core0site1"]

  group "tink" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 42114
      }

      port "grpc" {
        to = 42113
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "tink-http-cont"
      port = "http"

      task = "tink-server"

      address_mode = "alloc"
    }

    service {
      name = "tink-grpc-cont"
      port = "grpc"

      task = "tink-server"

      address_mode = "alloc"
    }

    task "tink-server" {
      driver = "docker"

      config {
        image = "quay.io/tinkerbell/tink:${Version}"
      }

      env {
        FACILITY = "onprem"

        PACKET_ENV = "testing"

        PACKET_VERSION = "ignored"
        ROLLBAR_TOKEN = "ignored"
        ROLLBAR_DISABLE = "1"

        TINKERBELL_GRPC_AUTHORITY = ":42113"
        TINKERBELL_HTTP_AUTHORITY = ":42114"

        TINK_AUTH_USERNAME = "${Admin.Username}"
        TINK_AUTH_PASSWORD = "${Admin.Password}"
      }


      template {
        data = <<EOH
#
# Database
#
PGDATABASE="${Database.Database}"
PGHOST="${Database.Hostname}"

PGUSER="${Database.Username}"
PGPASSWORD="${Database.Password}"


EOH

        destination = "secrets/file.env"
        env         = true
      }

      template {
        data = <<EOH
${TLS.CA}
${TLS.Cert}
EOH

        destination = "/certs/onprem/bundle.pem"
      }

      template {
        data = <<EOH
${TLS.Key}
EOH

        destination = "/certs/onprem/server-key.pem"
      }
    }
  }
}