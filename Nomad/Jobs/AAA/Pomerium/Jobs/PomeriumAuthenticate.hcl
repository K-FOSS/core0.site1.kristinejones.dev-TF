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

      tags = ["coredns.enabled", "https.authenticate"]

      #
      # Liveness check
      #
      check {
        port = "https"
        address_mode = "alloc"

        type = "http"
        protocol = "https"
        tls_skip_verify = true

        path = "/ping"
        interval = "15s"
        timeout  = "30s"

        check_restart {
          limit = 10
          grace = "60s"
        }
      }

      #
      # Readyness
      #
      check {
        port = "https"
        address_mode = "alloc"

        type = "http"
        protocol = "https"
        tls_skip_verify = true

        path = "/ping"
        interval = "10s"
        timeout  = "1s"
      }
    }

    task "pomerium-authenticate-server" {
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
          service = "authenticate"
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

            loki-external-labels = "job=pomerium,service=authenticate"
          }
        }
      }

      meta {
        SERVICE = "authenticate"
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