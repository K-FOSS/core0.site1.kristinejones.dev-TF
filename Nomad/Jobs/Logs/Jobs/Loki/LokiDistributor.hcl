job "loki-distributor" {
  datacenters = ["core0site1"]

  #
  # Loki Distributor
  #
  group "loki-distributor" {
    count = 1

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
      name = "loki"
      port = "http"

      task = "loki-distributor"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.distributor"]

      #
      # Liveness check
      #
      check {
        port = "http"
        address_mode = "alloc"

        type = "http"

        path = "/ready"
        interval = "15s"
        timeout  = "3s"

        check_restart {
          limit = 10
          grace = "10m"
        }
      }
    }

    service {
      name = "loki"
      port = "grpc"

      task = "loki-distributor"
      address_mode = "alloc"

      tags = ["coredns.enabled", "grpc.distributor"]
    }

    service {
      name = "loki"
      
      port = "gossip"
      address_mode = "alloc"

      task = "loki-distributor"

      tags = ["coredns.enabled", "gossip.distributor", "$${NOMAD_ALLOC_INDEX}.gossip.distributor"]
    }

    task "loki-distributor" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "60s"
      }

      config {
        image = "grafana/loki:${Loki.Version}"

        args = ["-config.file=/local/Loki.yaml"]

        memory_hard_limit = 128
      }

      meta {
        TARGET = "distributor"

        REPLICAS = "1"
      }

      resources {
        cpu = 64
        memory = 128
        memory_max = 128
      }

      template {
        data = <<EOF
${Loki.YAMLConfig}
EOF

        destination = "local/Loki.yaml"
      }
    }
  }
}