job "registry-harbor-registry" {
  datacenters = ["core0site1"]

  group "harbor-registry-redis" {
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

      task = "harbor-registry-cache"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis.registry"]

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

    task "harbor-registry-cache" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }

  group "harbor-registry-registry" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 443
      }

      port "metrics" {
        to = 9284
      }

      port "ctlhttps" {
        to = 9443
      }
    }

    service {
      name = "harbor"
      port = "https"

      task = "harbor-registry-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https.registry"]
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
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

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
        PORT = "443"

        #
        # Internal TLS
        #
        INTERNAL_TLS_ENABLED = "true"

        #
        # Internal Certs
        #
        INTERNAL_TLS_KEY_PATH = "/secrets/TLS/Cert.key"
        INTERNAL_TLS_CERT_PATH = "secrets/TLS/Cert.pem"

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
      port = "ctlhttps"

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
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

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
        PORT = "9443"

        #
        # Internal TLS
        #
        INTERNAL_TLS_ENABLED = "true"

        #
        # Internal Certs
        #
        INTERNAL_TLS_KEY_PATH = "/secrets/TLS/Cert.key"
        INTERNAL_TLS_CERT_PATH = "secrets/TLS/Cert.pem"

        #
        # Trusted CA
        #
        INTERNAL_TLS_TRUST_CA_PATH = "/local/CA.pem"

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
${Harbor.RegistryCTL.TLS.CA}
EOF

        destination = "local/CA.pem"
      }

      template {
        data = <<EOF
${Harbor.RegistryCTL.TLS.Cert}
EOF

        destination = "secrets/TLS/Cert.pem"
      }

      template {
        data = <<EOF
${Harbor.RegistryCTL.TLS.Key}
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
        env         = true
      }
    }
  }
}