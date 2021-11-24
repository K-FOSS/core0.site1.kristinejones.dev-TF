job "pomerium-proxy" {
  datacenters = ["core0site1"]

  group "pomerium-proxy" {
    count = 3

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 443
      }
    
      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "pomerium"
      port = "https"

      task = "pomerium-proxy-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https.proxy"]
    }

    task "pomerium-proxy-server" {
      driver = "docker"

      restart {
        attempts = 5
        delay    = "60s"
      }

      config {
        image = "pomerium/pomerium:${Version}"

        args = ["-config=/local/Pomerium.yaml"]

        labels {
          job = "pomerium"
          service = "proxy"
        }
      }

      meta {
        SERVICE = "proxy"
      }

      template {
        data = <<EOF
${Config}
EOF

        destination = "local/Pomerium.yaml"

        change_mode = "signal"
        change_signal = "SIGUSR1"
      }

      #
      # Server TLS
      #

      template {
        data = <<EOF
${TLS.Server.CA}
EOF

        destination = "local/ServerCA.pem"
      }

      template {
        data = <<EOF
${TLS.Server.Cert}
EOF

        destination = "secrets/TLS/Server.pem"
      }

      template {
        data = <<EOF
${TLS.Server.Key}
EOF

        destination = "secrets/TLS/Server.key"
      }

      #
      # Metrics TLS
      #
      template {
        data = <<EOF
${TLS.Metrics.Server.CA}
EOF

        destination = "local/MetricsServerCA.pem"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${TLS.Metrics.Server.Cert}
EOF

        destination = "secrets/TLS/Metrics.pem"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${TLS.Metrics.Server.Key}
EOF

        destination = "secrets/TLS/Metrics.key"

        change_mode = "noop"
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

      #
      # GitLab
      #
      # TODO: Proper mTLS
      #
      template {
        data = <<EOF
${TLS.GitLab.CA}
EOF

        destination = "secrets/TLS/GitLab.pem"
      }

      resources {
        cpu = 800
        memory = 256
      }
    }
  }

}