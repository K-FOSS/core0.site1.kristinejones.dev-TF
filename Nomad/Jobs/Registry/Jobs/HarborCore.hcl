job "registry-harbor-core" {
  datacenters = ["core0site1"]

  group "harbor-registry-core-server" {
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

      port "metrics" {
        to = 9090
      }

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13",
          "172.18.0.10"
        ]
      }
    }

    task "wait-for-harbor-core-redis" {
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

      task = "harbor-core-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.core"]
    }

    service {
      name = "harbor"
      port = "metrics"

      task = "harbor-core-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics.core"]
    }


    task "harbor-core-server" {
      driver = "docker"

      user = "root"

      config {
        image = "goharbor/harbor-core:${Harbor.Version}"

        entrypoint = ["/local/entry.sh"]

        memory_hard_limit = 512

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
        cpu = 256

        memory = 256
        memory_max = 512
      }

      env {
        #
        # Listen
        #
        PORT = "8443"

        EXT_ENDPOINT = "https://registry.kristianjones.dev"

        #
        # Secrets
        #
        KEY_PATH = "/secrets/KEY"

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
        CORE_URL = "https://http.core.harbor.service.dc1.kjdev"
        JOBSERVICE_URL = "https://http.jobservice.harbor.service.dc1.kjdev:8443"
        REGISTRY_URL = "https://https.registry.harbor.service.dc1.kjdev:5443"
        REGISTRY_CONTROLLER_URL = "https://https.registry.harbor.service.dc1.kjdev:8443"

        TOKEN_SERVICE_URL = "https://http.core.harbor.service.dc1.kjdev:8443/service/token"

        CORE_LOCAL_URL = "https://127.0.0.1:8443"

        PORTAL_URL = "https://http.portal.harbor.service.dc1.kjdev:8443"

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
        # Registry Proxy Cache
        # 
        PERMITTED_REGISTRY_TYPES_FOR_PROXY_CACHE = "docker-hub,harbor,azure-acr,aws-ecr,google-gcr,quay,docker-registry"

        #
        # Registry
        # 
        REGISTRY_STORAGE_PROVIDER_NAME = "s3"

        #
        # ChartMusuem
        #
        # TODO: Determine if this or 
        # GitLab or a mix of the both is worthwhile
        #
        WITH_CHARTMUSEUM = "true"
        CHART_REPOSITORY_URL = "https://https.chartmuseum.harbor.service.kjdev:8443"

        #
        # Misc
        #
        LOG_LEVEL = "DEBUG"

        #
        # Cache
        #
        CHART_CACHE_DRIVER = "redis"

        _REDIS_URL_CORE = "redis://redis.harbor.service.dc1.kjdev:6379?db=4"
        _REDIS_URL_REG = "redis://redis.harbor.service.dc1.kjdev:6379?db=0"

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
        data = "${Harbor.Secrets.CoreSecretKey}"

        destination = "secrets/KEY"
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
        data = <<EOF
${Harbor.TLS.Key}
EOF

        destination = "local/Secrets/Key.pem"
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