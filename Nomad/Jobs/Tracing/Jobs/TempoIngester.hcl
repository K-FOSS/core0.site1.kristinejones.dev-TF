job "tempo-ingester" {
  datacenters = ["core0site1"]

  group "tempo-ingester" {
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

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    service {
      name = "tempo"
      port = "http"

      task = "tempo-ingester"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.ingester"]
    }

    service {
      name = "tempo"
      port = "grpc"

      task = "tempo-ingester"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc.ingester"]
    }

    service {
      name = "tempo"
      
      port = "gossip"
      address_mode = "alloc"

      task = "tempo-ingester"

      tags = ["coredns.enabled", "gossip.ingester", "$${NOMAD_ALLOC_INDEX}.gossip.ingester"]
    }

    task "tempo-ingester" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "60s"
      }

      config {
        image = "grafana/tempo:${Tempo.Version}"

        args = ["-search.enabled=true", "-config.file=/local/Tempo.yaml"]

        memory_hard_limit = 512

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

            loki-external-labels = "job=tempo,service=ingester"
          }
        }
      }

      meta {
        TARGET = "ingester"
      }

      resources {
        cpu = 128

        memory = 256
        memory_max = 512
      }

      template {
        data = <<EOF
${Tempo.YAMLConfig}
EOF

        destination = "local/Tempo.yaml"

        # Config Replacement
        change_mode = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}