job "registry-harbor-portal" {
  datacenters = ["core0site1"]

  group "harbor-registry-portal" {
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

    task "wait-for-harbor-core-redis" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z http.core.harbor.service.dc1.kjdev 8443; do sleep 1; done"]
      }
    }

    service {
      name = "harbor"
      port = "http"

      task = "harbor-portal-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.portal"]
    }


    task "harbor-portal-server" {
      driver = "docker"

      config {
        image = "goharbor/harbor-portal:${Harbor.Version}"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=harbor,service=portal"
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

        destination = "local/Harbor/NGINX.conf"
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
    }
  }
}