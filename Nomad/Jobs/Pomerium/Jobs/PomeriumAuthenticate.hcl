job "pomerium-authenticate" {
  datacenters = ["core0site1"]

  group "pomerium-authenticate" {
    count = 3

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 443
      }

      port "metrics" {
        to = 9443
      }
    }

    service {
      name = "pomerium"
      port = "https"

      task = "pomerium-authenticate-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https.authenticate"]
    }

    task "pomerium-authenticate-server" {
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
          service = "authenticate"
        }
      }

      meta {
        SERVICE = "authenticate"
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

        change_mode = "noop"
      }

      template {
        data = <<EOF
${TLS.Server.Cert}
EOF

        destination = "secrets/TLS/Server.pem"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${TLS.Server.Key}
EOF

        destination = "secrets/TLS/Server.key"

        change_mode = "noop"
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

      resources {
        cpu = 800
        memory = 256
      }
    }
  }
}