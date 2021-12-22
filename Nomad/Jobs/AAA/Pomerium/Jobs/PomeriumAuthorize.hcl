job "pomerium-authorize" {
  datacenters = ["core0site1"]

  group "pomerium-authorize" {
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

      task = "pomerium-authorize-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.authorize"]

      #
      # Liveness check
      #
      check {
        name = "tcp_validate"

        type = "tcp"

        port = "https"
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

    task "pomerium-authorize-server" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "60s"
      }

      config {
        image = "${Pomerium.Image.Repo}:${Pomerium.Image.Tag}"

        args = ["-config=/local/Pomerium.yaml"]

        labels {
          job = "pomerium"
          service = "authorize"
        }

        mount {
          type = "tmpfs"
          target = "/root/.cache/pomerium"
          readonly = false
          tmpfs_options = {
            size = 124000000
          }
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=pomerium,service=authorize"
          }
        }
      }

      meta {
        SERVICE = "authorize"
      }

      env {
        ROUTES = "${Pomerium.Routes}"
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