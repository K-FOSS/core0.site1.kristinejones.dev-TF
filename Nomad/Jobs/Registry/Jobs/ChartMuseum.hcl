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
        WITH_CHARTMUSEUM = "false"
        #CHART_REPOSITORY_URL = ""

        #
        # Misc
        #
        LOG_LEVEL = "DEBUG"

        #
        # Cache
        #
        CHART_CACHE_DRIVER = "redis"

        _REDIS_URL_CORE = "redis://redis.core.harbor.service.dc1.kjdev:6379"
        _REDIS_URL_REG = "redis://redis.registry.harbor.service.dc1.kjdev:6379"

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
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }
}