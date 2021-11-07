job "prometheus" {
  datacenters = ["core0site1"]

  group "prometheus-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      dns {
        servers = [
          "172.16.0.153:53",
          "172.16.0.10:8600",
          "172.16.0.11:8600",
          "172.16.0.12:8600",
          "172.16.0.13:8600"
        ]
      }
    }

    task "prometheus" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "60s"
      }

      config {
        image = "prom/prometheus:${Prometheus.Version}"

        args = ["--config.file=/local/prometheus.yaml", "--enable-feature=exemplar-storage"]
      }

      template {
        data = <<EOF
${Prometheus.YAMLConfig}
EOF

        destination = "local/prometheus.yaml"
        
        # Config Replacement
        change_mode = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
${Prometheus.Grafana.CA}
EOF

        destination = "local/GrafanaCA.pem"

        change_mode = "noop"
      }
    }
  }
}