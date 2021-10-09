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

%{ for Service in Services ~}
  group "pomerium-${Service.name}" {
    count = ${Service.count}

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 443
      }

      port "grpc" { 
        to = 443
      }
    }

    service {
      name = "pomerium-${Service.name}-https-cont"
      port = "https"

      task = "pomerium-${Service.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    service {
      name = "pomerium-${Service.name}-grpc-cont"
      port = "grpc"

      task = "pomerium-${Service.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-${Service.name}" {
      driver = "docker"

      restart {
        attempts = 5
        delay    = "60s"
      }

      config {
        image = "pomerium/pomerium:${Version}"

        args = ["-config=/local/pomerium.yaml"]

        labels {
          job = "pomerium"
          service = "${Service.name}"
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
            loki-external-labels = "job=pomerium,service=authenticate"
          }
        }
      }

      meta {
        SERVICE = "${Service.name}"
      }

      template {
        data = <<EOF
${YAMLConfig}
EOF

        destination = "local/Pomerium.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${Service.TLS.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${Service.TLS.Key}
EOF

        destination = "local/cert.key"
      }

      resources {
        cpu    = 800
        memory = 500
      }
    }
  }
%{ endfor ~}
}