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

      task = "harbor-redis"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]

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
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 443
      }

      port "metrics" {
        to = 9284
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

      config {
        image = "goharbor/harbor-jobservice:${Harbor.Version}"

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
        PORT = "443"

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
        # Logs
        #
        CORE_URL = "https://http.core.harbor.service.dc1.kjdev"
        TOKEN_SERVICE_URL = "https://http.tokenservice.harbor.service.dc1.kjdev"
        REGISTRY_URL = "https://http.registry.harbor.service.dc1.kjdev"
        REGISTRY_CONTROLLER_URL = "https://http.registrycontroller.harbor.service.dc1.kjdev"
        REGISTRY_CREDENTIAL_USERNAME = "TODO"

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
    }
  }
}