job "grafana" {
  datacenters = ["core0site1"]

  group "grafana" {
    count = 1

    network {
      mode = "bridge"

      port "http" { }
    }

    service {
      name = "grafana-cont"
      port = "http"

      task = "grafana-web"

      connect {
        sidecar_service {}
      }
    }

    task "grafana-web" {
      driver = "docker"

      config {
        image = "grafana/grafana:8.0.3"

        args = ["-config=/local/grafana.ini"]
      }

      env {
        GF_LOG_MODE = "console"
      }

      template {
        data = <<EOF
${Config}
EOF

        destination = "local/grafana.ini"
      }
    }
  }
}