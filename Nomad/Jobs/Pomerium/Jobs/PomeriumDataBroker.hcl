job "pomerium-databroker" {
  datacenters = ["core0site1"]

  group "pomerium-databroker" {
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

    task "wait-for-redis" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z redis.pomerium.service.dc1.kjdev 6379; do sleep 1; done"]
      }
    }

    service {
      name = "pomerium"
      port = "https"

      task = "pomerium-databroker-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https.databroker"]
    }

    task "pomerium-databroker-server" {
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
          service = "databroker"
        }
      }

      meta {
        SERVICE = "databroker"
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
${TLS.Metrics.CA}
EOF

        destination = "local/MetricsServerCA.pem"
      }

      template {
        data = <<EOF
${TLS.Metrics.Cert}
EOF

        destination = "secrets/TLS/Metrics.pem"
      }

      template {
        data = <<EOF
${TLS.Metrics.Key}
EOF

        destination = "secrets/TLS/Metrics.key"
      }

      resources {
        cpu = 800
        memory = 256
      }
    }
  }

}