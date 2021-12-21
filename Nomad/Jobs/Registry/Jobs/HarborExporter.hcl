job "registry-harbor-exporter" {
  datacenters = ["core0site1"]

  group "harbor-registry-exporter" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8443
      }
    }

    task "wait-for-harbor-core" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z http.core.harbor.service.dc1.kjdev 8443; do sleep 1; done"]
      }

      resources {
        cpu = 16
        memory = 16
      }
    }

    service {
      name = "harbor"
      port = "http"

      task = "harbor-exporter-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https.exporter"]
    }


    task "harbor-exporter-server" {
      driver = "docker"

      user = "root"

      config {
        image = "goharbor/harbor-exporter:${Harbor.Version}"

        entrypoint = ["/local/entry.sh"]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=harbor,service=exporter"
          }
        }
      }

      env {
        #
        # Internal TLS
        #
        INTERNAL_TLS_ENABLED = "true"

        #
        # Internal Certs
        #
        INTERNAL_TLS_KEY_PATH = "/secrets/TLS/Cert.key"
        INTERNAL_TLS_CERT_PATH = "/secrets/TLS/Cert.pem"

        #
        # Trusted CA
        #
        INTERNAL_TLS_TRUST_CA_PATH = "/local/CA.pem"

        #
        # URLs
        #
        CORE_URL = "https://http.core.harbor.service.dc1.kjdev:8443"

        TOKEN_SERVICE_URL = "https://http.core.harbor.service.dc1.kjdev:8443/service/token"
        REGISTRY_URL = "https://https.registry.harbor.service.dc1.kjdev:5443"
        REGISTRY_CONTROLLER_URL = "https://https.registry.harbor.service.dc1.kjdev:8443"

        #
        # Redis
        #
        HARBOR_REDIS_URL = "redis://redis.harbor.service.dc1.kjdev:6379"
        HARBOR_REDIS_NAMESPACE = "harbor_job_service_namespace"
        HARBOR_REDIS_TIMEOUT = "3600"

        #
        # Exporter
        #
        HARBOR_EXPORTER_PORT = "8443"
        HARBOR_EXPORTER_METRICS_ENABLED = "true"
        HARBOR_EXPORTER_METRICS_PATH = "/metrics"

        #
        # Metrics
        #
        METRIC_NAMESPACE = "harbor"
        METRIC_SUBSYSTEM = "exporter"

        #
        # Services
        #
        HARBOR_SERVICE_SCHEME = "https"
        HARBOR_SERVICE_HOST = "http.core.harbor.service.dc1.kjdev"
        HARBOR_SERVICE_PORT = "8443"


        #
        # Tracing
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
        data = <<EOF
${Harbor.TLS.CA}
EOF

        destination = "local/CA.pem"
      }

      template {
        data = <<EOF
${Harbor.TLS.Cert}
EOF

        destination = "secrets/TLS/Cert.pem"
      }

      template {
        data = <<EOF
${Harbor.TLS.Key}
EOF

        destination = "secrets/TLS/Cert.key"
      }

      template {
        data = <<EOH
#
# Secret Keys
#
CORE_SECRET="${Harbor.Secrets.Core}"
JOBSERVICE_SECRET="${Harbor.Secrets.JobService}"

HARBOR_DATABASE_HOST="${Harbor.Database.Hostname}"
HARBOR_DATABASE_PORT="${Harbor.Database.Port}"

HARBOR_DATABASE_DBNAME="${Harbor.Database.Database}"

HARBOR_DATABASE_USERNAME="${Harbor.Database.Username}"
HARBOR_DATABASE_PASSWORD="${Harbor.Database.Password}"

#
# Misc
#
CSRF_KEY="${Harbor.Secrets.CSRFKey}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }
}