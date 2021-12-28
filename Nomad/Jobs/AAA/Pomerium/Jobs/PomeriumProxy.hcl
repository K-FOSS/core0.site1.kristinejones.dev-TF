job "pomerium-proxy" {
  datacenters = ["core0site1"]

  group "pomerium-proxy" {
    count = 3

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 443
      }

      port "metrics" {
        to = 9443
      }
    
      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    service {
      name = "pomerium"
      port = "https"

      task = "pomerium-proxy-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.proxy"]

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

    service {
      name = "pomerium"
      port = "metrics"

      task = "pomerium-proxy-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "metrics.proxy"]
    }

    task "pomerium-proxy-server" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "60s"
      }

      config {
        image = "${Pomerium.Image.Repo}:${Pomerium.Image.Tag}"

        args = ["-config=/local/Pomerium.yaml"]

        memory_hard_limit = 256

        labels {
          job = "pomerium"
          service = "proxy"
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

            loki-external-labels = "job=pomerium,service=proxy"
          }
        }
      }

      meta {
        SERVICE = "proxy"
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
        cpu = 64

        memory = 128
        memory_max = 256
      }
    }
  }

}