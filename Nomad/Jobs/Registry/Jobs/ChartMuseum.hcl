job "registry-harbor-chartmuseum" {
  datacenters = ["core0site1"]

  group "harbor-chartmuseum-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "harbor"
      port = "redis"

      task = "harbor-chartmuseum-cache"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis.chartmuseum"]

      check {
        name = "tcp_validate"

        type = "tcp"

        port = "redis"
        address_mode = "alloc"

        initial_status = "passing"

        interval = "30s"
        timeout  = "10s"

        check_restart {
          limit = 6
          grace = "120s"
          ignore_warnings = true
        }
      }
    }

    task "harbor-chartmuseum-cache" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }

  group "harbor-registry-chartmuseum-server" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 8443
      }

      port "metrics" {
        to = 9090
      }
    }

    task "wait-for-harbor-chartmuseum-redis" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z redis.chartmuseum.harbor.service.dc1.kjdev 6379; do sleep 1; done"]
      }

      resources {
        cpu = 16
        memory = 16
        memory_max = 32
      }
    }

    service {
      name = "harbor"
      port = "https"

      task = "harbor-chartmuseum-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.chartmuseum"]

      #
      # Liveness check
      #
      check {
        port = "https"
        address_mode = "alloc"

        type = "http"
        protocol = "https"
        tls_skip_verify = true

        path = "/"
        interval = "10s"
        timeout  = "30s"

        check_restart {
          limit = 10
          grace = "60s"
        }
      }
    }

    service {
      name = "harbor"
      port = "metrics"

      task = "harbor-chartmuseum-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics.chartmuseum"]
    }


    task "harbor-chartmuseum-server" {
      driver = "docker"

      user = "root"

      config {
        image = "goharbor/chartmuseum-photon:${ChartMuseum.Version}"

        entrypoint = ["/local/entry.sh"]

        mount {
          type = "bind"
          target = "/etc/core/private_key.pem"
          source = "local/Secrets/Key.pem"
          readonly = true
          bind_options {
            propagation = "rshared"
          }
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=harbor,service=core"
          }
        }
      }

      resources {
        cpu = 512
        memory = 256
        memory_max = 256
      }

      env {
        #
        # Listen
        #
        PORT = "8443"

        EXT_ENDPOINT = "https://registry.kristianjones.dev"
        
        #
        # TODO: What dis do?
        #
        #CHART_URL = ""

        #
        # Security
        #
        AUTH_ANONYMOUS_GET = "false"
        ALLOW_OVERWRITE = "true"
        MAX_STORAGE_OBJECTS = "0"
        MAX_UPLOAD_SIZE = "20971520"

        #
        # Form Settings
        #
        CHART_POST_FORM_FIELD_NAME = "chart"
        PROV_POST_FORM_FIELD_NAME = "prov"


        #
        # Secrets
        #
        KEY_PATH = "/secrets/KEY"

        BASIC_AUTH_USER = "chart_controller"

        #
        # Internal Certs
        #
        TLS_CERT = "/secrets/TLS/Cert.key"
        TLS_KEY = "/secrets/TLS/Cert.pem"


        #
        # Cache
        #
        CACHE = "redis"
        CACHE_REDIS_ADDR = "redis.chartmuseum.harbor.service.kjdev"
        CACHE_REDIS_DB = "0"

        #
        # Trusted CA
        #
        INTERNAL_TLS_TRUST_CA_PATH = "/local/CA.pem"

        #
        # Storage
        #
        STORAGE = "amazon"
        STORAGE_TIMESTAMP_TOLERANCE = "1s"

        #
        # Tracing
        #

        #
        # Logs
        #
        LOG_JSON = "true"
        DISABLE_METRICS = "false"
        DISABLE_API = "false"
        DISABLE_STATEFILES = "false"

        # TODO: Determine if I can export to Tempo
        #
        #
        # Metrics
        #
        TRACE_ENABLED = "true"
        TRACE_SAMPLE_RATE = "1"
        TRACE_JAEGER_ENDPOINT = "http://http.distributor.tempo.service.kjdev:14268/api/traces"
      }

      template {
        data = <<EOF
${EntryScript}
EOF

        destination = "local/entry.sh"

        perms = "777"
      }

      template {
        data = "${ChartMuseum.Secrets.CoreSecretKey}"

        destination = "secrets/KEY"
      }

      template {
        data = <<EOF
${ChartMuseum.TLS.CA}
EOF

        destination = "local/CA.pem"
      }

      template {
        data = <<EOF
${ChartMuseum.TLS.Cert}
EOF

        destination = "secrets/TLS/Cert.pem"
      }

      template {
        data = <<EOF
${ChartMuseum.TLS.Key}
EOF

        destination = "secrets/TLS/Cert.key"
      }

      template {
        data = <<EOF
${ChartMuseum.TLS.Key}
EOF

        destination = "local/Secrets/Key.pem"
      }

      template {
        data = <<EOH
#
# Secret Keys
#
CORE_SECRET="${ChartMuseum.Secrets.Core}"
JOBSERVICE_SECRET="${ChartMuseum.Secrets.JobService}"

POSTGRESQL_HOST="${ChartMuseum.Database.Hostname}"
POSTGRESQL_PORT="${ChartMuseum.Database.Port}"

POSTGRESQL_DATABASE="${ChartMuseum.Database.Database}"

POSTGRESQL_USERNAME="${ChartMuseum.Database.Username}"
POSTGRESQL_PASSWORD="${ChartMuseum.Database.Password}"

#
# Misc
#
CSRF_KEY="${ChartMuseum.Secrets.CSRFKey}"

#
# Storage
#
STORAGE_AMAZON_BUCKET="${ChartMuseum.S3.Bucket}"
STORAGE_AMAZON_REGION="us-east-1"

STORAGE_AMAZON_ENDPOINT="http://${ChartMuseum.S3.Connection.Endpoint}"
AWS_ACCESS_KEY_ID="${ChartMuseum.S3.Credentials.AccessKey}"
AWS_SECRET_ACCESS_KEY="${ChartMuseum.S3.Credentials.SecretKey}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }
}