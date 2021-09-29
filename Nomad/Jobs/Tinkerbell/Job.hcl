job "tinkerbell" {
  datacenters = ["core0site1"]

  group "tink" {
    count = 1

    update {
      max_parallel      = 1
      health_check      = "checks"
      min_healthy_time  = "10s"
      healthy_deadline  = "3m"
      progress_deadline = "5m"
    }

    restart {
      attempts = 3
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { }

      port "grpc" { }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "tink-http-cont"
      port = "http"

      task = "tink-server"

      address_mode = "alloc"

      check {
        port     = "http"
        address_mode = "alloc"

        type     = "http"
        path     = "/cert"
        interval = "5s"
        timeout  = "2s"
      }
    }

    service {
      name = "tink-grpc-cont"
      port = "grpc"

      task = "tink-server"

      address_mode = "alloc"

      check {
        port     = "http"
        address_mode = "alloc"

        type     = "http"
        path     = "/cert"
        interval = "5s"
        timeout  = "2s"
      }
    }


    

    task "tink-db" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

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

        ONLY_MIGRATION = "true"
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

        TINKERBELL_GRPC_AUTHORITY = ":$${NOMAD_PORT_grpc}"
        TINKERBELL_HTTP_AUTHORITY = ":$${NOMAD_PORT_http}"

        TINK_AUTH_USERNAME = "${Admin.Username}"
        TINK_AUTH_PASSWORD = "${Admin.Password}"

        TINKERBELL_CERTS_DIR = "/local/tls"
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
${TLS.Cert}
${TLS.CA}
EOH

        destination = "local/tls/bundle.pem"
      }

      template {
        data = <<EOH
${TLS.Key}
EOH

        destination = "local/tls/server-key.pem"
      }
    }
  }
}