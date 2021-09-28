job "pomerium" {
  datacenters = ["core0site1"]

  group "pomerium-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "pomerium-redis"
      port = "redis"

      task = "redis"

      address_mode = "alloc"
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6-alpine"

        command = "redis-server"

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }
    }
  }

%{ for Target in Services ~}
  group "pomerium-${Target.name}" {
    count = ${Target.count}

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "grpc" {
        to = 8080
      }
    }

    service {
      name = "pomerium-${Target.name}-http-cont"
      port = "http"

      task = "pomerium-${Target.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    service {
      name = "pomerium-${Target.name}-grpc-cont"
      port = "grpc"

      task = "pomerium-${Target.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-${Target.name}" {
      driver = "docker"

      restart {
        attempts = 5
        delay    = "60s"
      }

      config {
        image = "pomerium/pomerium:${Version}"

        args = ["-config", "/local/pomerium.yaml"]

        ulimit {
          nproc = "32768"
        }
      }

      env {
        Service = "${Target.name}"
      }

      meta {
        Service = "${Target.name}"
      }

      template {
        data = <<EOF
${YAMLConfig}
EOF

        destination = "local/pomerium.yaml"
      }
    }
  }
%{ endfor ~}
}