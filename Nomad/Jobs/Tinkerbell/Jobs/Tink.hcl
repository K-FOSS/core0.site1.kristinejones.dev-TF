job "tinkerbell-tink" {
  datacenters = ["core0site1"]

  group "tink" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    update {
      max_parallel = 1
      health_check = "checks"
      min_healthy_time = "10s"
      healthy_deadline = "3m"
      progress_deadline = "5m"
    }

    restart {
      attempts = 3
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 42114
      }

      port "grpc" {
        to = 42113
      }
    }

    service {
      name = "tink-http-cont"
      port = "http"

      task = "tink-server"
      address_mode = "alloc"

      check {
        port = "http"
        address_mode = "alloc"

        type = "http"
        path = "/cert"
        interval = "5s"
        timeout = "2s"
      }
    }

    service {
      name = "tink-grpc-cont"
      port = "grpc"

      task = "tink-server"

      address_mode = "alloc"

      check {
        port = "http"
        address_mode = "alloc"

        type = "http"
        path = "/cert"
        interval = "5s"
        timeout = "2s"
      }
    }

    #
    # Task to Provision the database
    #
    task "tink-db" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "docker"

      config {
        image = "quay.io/tinkerbell/tink:${Version}"
      }

      resources {
        cpu = 32
        memory = 32
        memory_max = 64
      }

      env {
        FACILITY = "onprem"

        PACKET_ENV = "testing"

        #
        # Packet
        #
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
PGPORT="${Database.Port}"

PGUSER="${Database.Username}"
PGPASSWORD="${Database.Password}"


EOH

        destination = "secrets/file.env"
        env = true
      }

    }

    task "tink-server" {
      driver = "docker"

      config {
        image = "quay.io/tinkerbell/tink:${Version}"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=tinkerbell,service=tink"
          }
        }
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

        TINKERBELL_CERTS_DIR = "/local/tls"
      }


      template {
        data = <<EOH
#
# Database
#
PGDATABASE="${Database.Database}"
PGHOST="${Database.Hostname}"
PGPORT="${Database.Port}"

PGUSER="${Database.Username}"
PGPASSWORD="${Database.Password}"


EOH

        destination = "secrets/file.env"
        env = true
      }

      template {
        data = <<EOH
${TLS.Tink.Cert}
${TLS.CA}
EOH

        destination = "local/tls/bundle.pem"
      }

      template {
        data = <<EOH
${TLS.Tink.Key}
EOH

        destination = "local/tls/server-key.pem"
      }
    }
  }

  #
  # Tinkerbell Hegel
  #
  # Hegel is Tinkerbell's metadata store, supporting storage and retrieval of metadata over gRPC and HTTP. 
  # It also provides a compatible layer with the AWS EC2 metadata format.
  #
  # Docs: https://docs.tinkerbell.org/services/hegel/
  #
  #
  # Tinkerbell Hegel
  #
  # Hegel is Tinkerbell's metadata store, supporting storage and retrieval of metadata over gRPC and HTTP. 
  # It also provides a compatible layer with the AWS EC2 metadata format.
  #
  # Docs: https://docs.tinkerbell.org/services/hegel/
  # 
  group "hegel" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight    = 100
    }

    restart {
      attempts = 3
      interval = "5m"
      delay = "60s"
      mode = "delay"
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "grpc" {
        to = 8085
      }
    }

    task "wait-for-tink" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z tink-http-cont.service.dc1.kjdev 42114; do sleep 1; done"]
      }

      resources {
        cpu = 16
        memory = 16
      }
    }

    service {
      name = "tink-hegel-grpc-cont"
      port = "grpc"

      task = "hegel-server"

      address_mode = "alloc"
    }

    task "hegel-server" {
      driver = "docker"

      config {
        image = "quay.io/tinkerbell/hegel:${Version}"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=tinkerbell,service=hegel"
          }
        }
      }

      env {
        FACILITY = "onprem"
        PACKET_ENV = "testing"

        PACKET_VERSION = "ignored"
        ROLLBAR_TOKEN = "ignored"
        ROLLBAR_DISABLE = "1"

        GRPC_PORT = "$${NOMAD_PORT_grpc}"
        HEGEL_HTTP_PORT = "$${NOMAD_PORT_http}"

        TINK_AUTH_USERNAME = "${Admin.Username}"
        TINK_AUTH_PASSWORD = "${Admin.Password}"

        HEGEL_FACILITY = "onprem"
        HEGEL_USE_TLS = "1"

        TINKERBELL_GRPC_AUTHORITY = "tink-grpc-cont.service.dc1.kjdev:42113"
        TINKERBELL_CERT_URL = "http://tink-http-cont.service.dc1.kjdev:42114/cert"

        DATA_MODEL_VERSION = "1"

        CUSTOM_ENDPOINTS = "{\"/metadata\":\"\"}"

        #
        # TLS
        # 
        HEGEL_TLS_CERT = "/local/tls/bundle.pem"
        HEGEL_TLS_KEY = "/local/tls/key.pem"
      }


      template {
        data = <<EOH
#
# Database
#
PGDATABASE="${Database.Database}"
PGHOST="${Database.Hostname}"
PGPORT="${Database.Port}"

PGUSER="${Database.Username}"
PGPASSWORD="${Database.Password}"
EOH

        destination = "secrets/file.env"
        env         = true
      }

      template {
        data = <<EOH
${TLS.Hegel.Cert}
${TLS.CA}
EOH

        destination = "local/tls/bundle.pem"
      }

      template {
        data = <<EOH
${TLS.Hegel.Key}
EOH

        destination = "local/tls/key.pem"
      }

      resources {
        cpu = 64
        memory = 32
        memory_max = 64
      }
    }
  }
}