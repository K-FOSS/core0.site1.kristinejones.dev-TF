job "tempo-distributor" {
  datacenters = ["core0site1"]

  group "tempo-distributor" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "grpc" { 
        to = 8085
      }

      port "gossip" { 
        to = 8090
      }
      
      port "otel_grpc" {
        to = 4317
      }
    }

    service {
      name = "tempo"
      port = "http"

      task = "tempo-distributor"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.distributor"]
    }

    service {
      name = "tempo"
      port = "grpc"

      task = "tempo-distributor"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc.distributor"]
    }

    service {
      name = "tempo"
      
      port = "gossip"
      address_mode = "alloc"

      task = "tempo-distributor"

      tags = ["coredns.enabled", "gossip.distributor", "$${NOMAD_ALLOC_INDEX}.gossip.distributor"]
    }

    service {
      name = "tempo"
      
      port = "otel_grpc"
      address_mode = "alloc"

      task = "tempo-distributor"

      tags = ["coredns.enabled", "grpc.otel"]
    }

    task "tempo-distributor" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "60s"
      }

      config {
        image = "grafana/tempo:${Tempo.Version}"

        args = ["-search.enabled=true", "-config.file=/local/Tempo.yaml"]

        memory_hard_limit = 256

        mount {
          type = "tmpfs"
          target = "/var/tempo/wal"
          readonly = false
          tmpfs_options = {
            size = 1000000000
          }
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=tempo,service=distributor"
          }
        }
      }

      meta {
        TARGET = "distributor"
      }

      resources {
        cpu = 128

        memory = 64
        memory_max = 256
      }

      template {
        data = <<EOF
${Tempo.YAMLConfig}
EOF

        destination = "local/Tempo.yaml"
      }
    }
  }
}