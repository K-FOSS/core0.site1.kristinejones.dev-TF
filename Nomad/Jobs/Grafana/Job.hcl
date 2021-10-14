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

        port     = "redis"
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
        protocol = "https"
        tls_skip_verify = true

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
apiVersion: 1

datasources:
  - name: 'Tempo'
    type: tempo
    access: proxy
    orgId: 1
    url: http://tempo-query-frontend-http-cont.service.kjdev:8080
    basicAuth: false
    isDefault: false
    version: 1
    editable: false
    apiVersion: 1
    uid: tempo-query
EOF

        destination = "local/provisioning/datasources/datasources.yaml"
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
    }
  }
}