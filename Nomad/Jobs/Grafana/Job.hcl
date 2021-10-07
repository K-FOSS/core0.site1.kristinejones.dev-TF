job "grafana" {
  datacenters = ["core0site1"]

  group "grafana" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 8080
      }
    }

    service {
      name = "grafana-cont"
      port = "http"

      task = "grafana-web"

      address_mode = "alloc"
    }

    task "grafana-web" {
      driver = "docker"

      config {
        image = "grafana/grafana:${Version}"

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