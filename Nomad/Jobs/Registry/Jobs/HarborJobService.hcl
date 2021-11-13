job "registry-harbor-jobservice" {
  datacenters = ["core0site1"]

  group "harbor-redis" {
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

      task = "harbor"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis.jobservice"]

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

    task "harbor-cache" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }

  group "harbor-registry-jobservice" {
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
        to = 9284
      }
    }

    task "wait-for-harbor-jobservice-redis" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z redis.jobservice.harbor.service.dc1.kjdev 6379; do sleep 1; done"]
      }
    }

    service {
      name = "harbor"
      port = "http"

      task = "harbor-jobservice-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.jobservice"]
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
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

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
        TRACE_ENABLED = "true"
        TRACE_SAMPLE_RATE = "1"
        TRACE_JAEGER_ENDPOINT = "http://tempo-distributor-http-cont.service.kjdev:14268/api/traces"
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