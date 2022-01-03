job "loki-query-scheduler" {
  datacenters = ["core0site1"]

  #
  # Loki Query Scheduler
  #
  group "loki-query-scheduler" {
    count = 4

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

      task = "loki-query-scheduler"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.query-scheduler"]

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

      task = "loki-query-scheduler"
      address_mode = "alloc"

      tags = ["coredns.enabled", "grpc.query-scheduler", "$${NOMAD_ALLOC_INDEX}.grpc.query-scheduler"]
    }

    service {
      name = "loki"
      
      port = "gossip"
      address_mode = "alloc"

      task = "loki-query-scheduler"

      tags = ["coredns.enabled", "gossip.query-scheduler", "$${NOMAD_ALLOC_INDEX}.gossip.query-scheduler"]
    }

    task "loki-query-scheduler" {
      driver = "docker"

      kill_timeout = 120

      restart {
        attempts = 5
        delay = "60s"
      }

      config {
        image = "grafana/loki:${Loki.Version}"

        args = ["-config.file=/local/Loki.yaml"]

        memory_hard_limit = 256
      }

      meta {
        TARGET = "query-scheduler"

        REPLICAS = "3"
      }

      resources {
        cpu = 64

        memory = 128
        memory_max = 256
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