job "registry-harbor-portal" {
  datacenters = ["core0site1"]

  priority = 100

  group "harbor-registry-portal" {
    count = 3

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
        to = 9284
      }

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13"
        ]
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
      port = "https"

      task = "harbor-portal-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.portal"]

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


    task "harbor-portal-server" {
      driver = "docker"

      user = "root"

      config {
        image = "goharbor/harbor-portal:${Harbor.Version}"

        entrypoint = ["/local/entry.sh"]

        memory_hard_limit = 256

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

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

      resources {
        cpu = 256

        memory = 128
        memory_max = 256
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