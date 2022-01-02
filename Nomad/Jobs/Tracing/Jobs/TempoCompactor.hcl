job "tempo-compactor" {
  datacenters = ["core0site1"]

  group "tempo-compactor" {
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
    }

    service {
      name = "tempo"
      port = "http"

      task = "tempo-compactor"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.compactor"]
    }

    service {
      name = "tempo"
      port = "grpc"

      task = "tempo-compactor"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc.compactor"]
    }

    service {
      name = "tempo"
      
      port = "gossip"
      address_mode = "alloc"

      task = "tempo-compactor"

      tags = ["coredns.enabled", "gossip.compactor", "$${NOMAD_ALLOC_INDEX}.gossip.compactor"]
    }

    task "tempo-compactor" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "60s"
      }

      config {
        image = "grafana/tempo:${Tempo.Version}"

        args = ["-search.enabled=true", "-config.file=/local/Tempo.yaml"]

        memory_hard_limit = 512

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=tempo,service=compactor"
          }
        }
      }

      meta {
        TARGET = "compactor"
      }
    
      resources {
        cpu = 128

        memory = 64
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