job "registry-harbor-jobservice" {
  datacenters = ["core0site1"]

  group "harbor-registry-jobservice" {
    count = 4

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8443
      }

      port "metrics" {
        to = 9090
      }
    }

    task "wait-for-harbor-redis" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z redis.harbor.service.dc1.kjdev 6379; do sleep 1; done"]
      }

      resources {
        cpu = 16
        memory = 16
        memory_max = 32
      }
    }

    service {
      name = "harbor"
      port = "http"

      task = "harbor-jobservice-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.jobservice"]
    }

    service {
      name = "harbor"
      port = "metrics"

      task = "harbor-jobservice-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics.jobservice"]
    }


    task "harbor-jobservice-server" {
      driver = "docker"

      user = "root"

      config {
        image = "goharbor/harbor-jobservice:${Harbor.Version}"

        entrypoint = ["/local/entry.sh"]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=harbor,service=jobservice"
          }
        }
      }

      env {
        #
        # Listener
        #
        PORT = "8443"

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
        # Metrics
        #
        METRIC_NAMESPACE = "harbor"
        METRIC_SUBSYSTEM = "jobservice"


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
${Harbor.Config}
EOF

        destination = "local/Harbor/Config.yaml"
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
EOH

        destination = "secrets/file.env"
        env = true
      }
    }
  }
}