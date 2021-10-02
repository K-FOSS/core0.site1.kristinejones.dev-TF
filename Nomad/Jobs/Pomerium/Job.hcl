job "pomerium" {
  datacenters = ["core0site1"]

  group "pomerium-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "pomerium-redis-cont"
      port = "redis"

      task = "redis"

      address_mode = "alloc"
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6-alpine"

        command = "redis-server"

        args = []

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=pomerium,service=redis"
          }
        }
      }
    }
  }

  group "pomerium-authenticate" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 443
      }
    }

    service {
      name = "pomerium-authenticate-cont"
      port = "http"

      task = "pomerium-server"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-authenticate-server" {
      driver = "docker"

      config {
        image = "pomerium/pomerium:${Version}"

        args = ["-config=/local/pomerium.yaml"]

        labels {
          job = "pomerium"
          service = "authenticate"
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
            loki-external-labels = "job=pomerium,service=authenticate"
          }
        }
      }

      template {
        data = <<EOF
${YAMLConfigs.Authenticate}
EOF

        destination = "local/pomerium.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${TLS.Authenticate.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.Authenticate.Key}
EOF

        destination = "local/cert.key"
      }

      resources {
        cpu    = 800
        memory = 500
      }
    }
  }

  group "pomerium-authorize" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 443
      }
    }

    service {
      name = "pomerium-authorize-cont"
      port = "http"

      task = "pomerium-server"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-authorize-server" {
      driver = "docker"

      config {
        image = "pomerium/pomerium:${Version}"

        args = ["-config=/local/pomerium.yaml"]

        labels {
          job = "pomerium"
          service = "authorize"
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
            loki-external-labels = "job=pomerium,service=authorize"
          }
        }
      }

      template {
        data = <<EOF
${YAMLConfigs.Authorize}
EOF

        destination = "local/pomerium.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${TLS.Authorize.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.Authorize.Key}
EOF

        destination = "local/cert.key"
      }

      resources {
        cpu    = 800
        memory = 500
      }
    }
  }

  group "pomerium-databroker" {
    count = 3

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 443
      }
    }

    service {
      name = "pomerium-databroker-cont"
      port = "http"

      task = "pomerium-server"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-databroker-server" {
      driver = "docker"

      config {
        image = "pomerium/pomerium:${Version}"

        args = ["-config=/local/pomerium.yaml"]

        labels {
          job = "pomerium"
          service = "databroker"
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
            loki-external-labels = "job=pomerium,service=databroker"
          }
        }
      }

      template {
        data = <<EOF
${YAMLConfigs.DataBroker}
EOF

        destination = "local/pomerium.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${TLS.DataBroker.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.DataBroker.Key}
EOF

        destination = "local/cert.key"
      }

      resources {
        cpu    = 800
        memory = 500
      }
    }
  }

  group "pomerium-proxy" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 443
      }
    }

    service {
      name = "pomerium-proxy-cont"
      port = "http"

      task = "pomerium-server"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-proxy-server" {
      driver = "docker"

      config {
        image = "pomerium/pomerium:${Version}"

        args = ["-config=/local/pomerium.yaml"]
        
        labels {
          job = "pomerium"
          service = "proxy"
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
            loki-external-labels = "job=pomerium,service=proxy"
          }
        }
      }

      template {
        data = <<EOF
${YAMLConfigs.Proxy}
EOF

        destination = "local/pomerium.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${TLS.Proxy.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.Proxy.Key}
EOF

        destination = "local/cert.key"
      }

      resources {
        cpu    = 800
        memory = 500
      }
    }
  }
}