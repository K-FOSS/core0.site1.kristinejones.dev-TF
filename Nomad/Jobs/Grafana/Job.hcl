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

      tags = ["coredns.enabled"]

      check {
        name = "tcp_validate"

        type = "tcp"

        port = "redis"
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

    task "grafana-cache" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }

  group "grafana" {
    count = 4

    update {
      max_parallel = 1
      health_check = "checks"
      min_healthy_time = "30s"
      healthy_deadline = "5m"
      progress_deadline = "10m"
      auto_revert = true
    }

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

      tags = ["coredns.enabled"]

      #
      # Liveness check
      #
      check {
        port = "http"
        address_mode = "alloc"

        type = "http"
        protocol = "https"
        tls_skip_verify = true

        path = "/api/health"
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
        port = "http"
        address_mode = "alloc"

        type = "http"
        protocol = "https"
        tls_skip_verify = true

        path = "/api/health"
        interval = "10s"
        timeout  = "1s"
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
        GF_PATHS_PROVISIONING =	"/local/provisioning"
      }

      template {
        data = <<EOF
${Config}
EOF

        destination = "local/grafana.ini"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/TLS/CA.pem"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${TLS.Cert}
EOF

        destination = "local/TLS/cert.pem"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${TLS.Key}
EOF

        destination = "local/TLS/cert.key"

        change_mode = "noop"
      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 64
      }
    }
  }
}