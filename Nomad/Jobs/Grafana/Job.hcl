job "grafana" {
  datacenters = ["core0site1"]

  group "grafana-cache" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "grafana-cache"
      port = "redis"

      task = "grafana-cache"

      address_mode = "alloc"

      check {
        name     = "tcp_validate"

        type     = "tcp"

        port     = "http"
        address_mode = "alloc"

        port     = 6379
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "grafana-cache" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }

  group "grafana" {
    count = 3

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

      check {
        port     = "http"
        address_mode = "alloc"

        type     = "http"
        path     = "/api/health"
        interval = "30s"
        timeout  = "5s"
      }
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