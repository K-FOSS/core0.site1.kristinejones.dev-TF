job "pomerium-authorize" {
  datacenters = ["core0site1"]


  group "pomerium-authorize" {
    count = 3

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 443
      }
    }

    service {
      name = "pomerium"
      port = "https"

      task = "pomerium-authorize-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https.authorize"]
    }

    task "pomerium-authorize-server" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "60s"
      }

      config {
        image = "pomerium/pomerium:${Version}"

        args = ["-config=/local/Pomerium.yaml"]

        labels {
          job = "pomerium"
          service = "authorize"
        }
      }

      meta {
        SERVICE = "authorize"
      }

      template {
        data = <<EOF
${Config}
EOF

        destination = "local/Pomerium.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${Service.TLS.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${Service.TLS.Key}
EOF

        destination = "local/cert.key"
      }

      #
      # TLS & mTLS to end services
      #

      #
      # TODO: Get Grafana checking Pomerium client Certs
      #
      template {
        data = <<EOF
${TLS.Grafana.CA}
EOF

        destination = "secrets/TLS/GrafanaCA.pem"
      }

      #
      # HomeAssistant
      #
      # TODO: Proper mTLS
      #
      template {
        data = <<EOF
${TLS.HomeAssistant.CA}
EOF

        destination = "secrets/TLS/HomeAssistantCA.pem"
      }

      resources {
        cpu = 800
        memory = 256
      }
    }
  }
}