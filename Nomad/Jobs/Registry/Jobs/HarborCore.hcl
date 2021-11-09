job "registry-harbor-core" {
  datacenters = ["core0site1"]

  group "harbor-registry-server" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8888
      }

      port "metrics" {
        to = 9284
      }
    }

    service {
      name = "harbor"
      port = "http"

      task = "harbor-core-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.core"]
    }


    task "harbor-core-server" {
      driver = "docker"

      config {
        image = "goharbor/harbor-core:${Harbor.Version}"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=harbor,service=core"
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
        INTERNAL_TLS_KEY_PATH = "/escre"
        INTERNAL_TLS_CERT_PATH = ""

        #
        # Trusted CA
        #
        INTERNAL_TLS_TRUST_CA_PATH = "/local/CA.pem"

        #
        # Config
        # 
        CONFIG_PATH = "/local/Harbor/app.conf"

        #
        # Database
        #
        POSTGRESQL_SSLMODE = "disable"

        #
        # Service Connections
        #
        CORE_URL = ""
        JOBSERVICE_URL = ""
        REGISTRY_URL = ""
        TOKEN_SERVICE_URL = ""

        CORE_LOCAL_URL = "http://"

        #
        # Notary
        # 
        # TODO: Get Notary online?
        #
        WITH_NOTARY = "false"

        #
        # NOTARY_URL = ""
        #

        #
        # Trivy
        #
        # TODO: Learn more about this?
        #
        WITH_TRIVY = "false"
        # TRIVY_ADAPTER_URL = ""

        #
        # Registry
        # 
        REGISTRY_STORAGE_PROVIDER_NAME = ""

        #
        # ChartMusuem
        #
        # TODO: Determine if this or 
        # GitLab or a mix of the both is worthwhile
        #
        WITH_CHARTMUSEUM = "false"
        #CHART_REPOSITORY_URL = ""

        #
        # Misc
        #
        LOG_LEVEL = "DEBUG"

        #
        # Metrics
        #
        METRIC_ENABLE = "true"

        METRIC_NAMESPACE = "harbor"
        METRIC_SUBSYSTEM = "core"

        #
        # Tracing
        #
        # TODO: Determine if I can export to Tempo
        #


      }

      template {
        data = <<EOF
${Harbor.Config}
EOF

        destination = "local/Harbor/app.conf"
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

POSTGRESQL_HOST="${Harbor.Database.Hostname}"
POSTGRESQL_PORT="${Harbor.Database.Port}"

POSTGRESQL_DATABASE="${Harbor.Database.Database}"

POSTGRESQL_USERNAME="${Harbor.Database.Username}"
POSTGRESQL_PASSWORD="${Harbor.Database.Password}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }
}