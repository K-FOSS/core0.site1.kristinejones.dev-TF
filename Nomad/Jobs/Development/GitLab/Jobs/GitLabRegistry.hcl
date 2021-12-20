job "registry-harbor-registry" {
  datacenters = ["core0site1"]

  group "harbor-registry-registry" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "registryhttps" {
        to = 5443
      }

      port "metrics" {
        to = 9090
      }

      port "registryctlhttps" {
        to = 8443
      }
    }

    service {
      name = "gitlab"
      port = "registryhttps"

      task = "harbor-registry-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https.registry"]
    }

    service {
      name = "gitlab"
      port = "metrics"

      task = "harbor-registry-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics.registry"]
    }


    task "harbor-registry-server" {
      driver = "docker"

      user = "root"

      config {
        image = "goharbor/registry-photon:${Harbor.Version}"

        entrypoint = ["/local/entry.sh"]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=harbor,service=registry"
          }
        }
      }

      resources {
        cpu = 256
        memory = 256
        memory_max = 256
      }

      env {
        #
        # Port
        #
        PORT = "5443"

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
        # Metrics
        #
        METRIC_NAMESPACE = "harbor"
        METRIC_SUBSYSTEM = "registry"

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
${Harbor.Registry.Config}
EOF

        destination = "local/HarborRegistry/Config.yaml"
      }

      template {
        data = <<EOF
${Harbor.Registry.TLS.CA}
EOF

        destination = "local/CA.pem"
      }

      template {
        data = <<EOF
${Harbor.Registry.TLS.Cert}
EOF

        destination = "secrets/TLS/Cert.pem"
      }

      template {
        data = <<EOF
${Harbor.Registry.TLS.Key}
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

    service {
      name = "harbor"
      port = "registryctlhttps"

      task = "harbor-registry-ctl-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https.registrycontroller"]
    }

    task "harbor-registry-ctl-server" {
      driver = "docker"

      user = "root"

      config {
        image = "goharbor/harbor-registryctl:${Harbor.Version}"

        entrypoint = ["/local/entry.sh"]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=harbor,service=registry"
          }
        }
      }

      resources {
        cpu = 256
        memory = 256
        memory_max = 256
      }

      env {
        #
        # Port
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
        # Metrics
        #
        METRIC_NAMESPACE = "harbor"
        METRIC_SUBSYSTEM = "registryctl"
        TRACE_ENABLED = "true"
        TRACE_SAMPLE_RATE = "1"
        TRACE_JAEGER_ENDPOINT = "http://http.distributor.tempo.service.kjdev:14268/api/traces"

      }

      template {
        data = <<EOF
${Harbor.RegistryCTL.EntryScript}
EOF

        destination = "local/entry.sh"

        perms = "777"
      }

      template {
        data = <<EOF
${Harbor.Registry.Config}
EOF

        destination = "local/HarborRegistry/Config.yaml"
      }

      template {
        data = <<EOF
${Harbor.RegistryCTL.Config}
EOF

        destination = "local/HarborRegistryCTL/Config.yaml"
      }

      template {
        data = <<EOF
${Harbor.Registry.TLS.CA}
EOF

        destination = "local/CA.pem"
      }

      template {
        data = <<EOF
${Harbor.Registry.TLS.Cert}
EOF

        destination = "secrets/TLS/Cert.pem"
      }

      template {
        data = <<EOF
${Harbor.Registry.TLS.Key}
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