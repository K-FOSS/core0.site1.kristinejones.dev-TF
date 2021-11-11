job "cortex-queryfrontend" {
  datacenters = ["core0site1"]

  #
  # Cortex Query Frontend
  #
  group "cortex-query-frontend" {
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
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "cortex-query-frontend"
      port = "http"

      task = "cortex-query-frontend"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http"]

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
      name = "cortex-query-frontend"
      port = "grpc"

      task = "cortex-query-frontend"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc", "$${NOMAD_ALLOC_INDEX}.grpc"]
    }

    service {
      name = "cortex-query-frontend"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-query-frontend"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "gossip", "$${NOMAD_ALLOC_INDEX}.gossip"]
    }

    task "cortex-query-frontend" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "120s"
        mode = "delay"
      }

      kill_timeout = "120s"



      config {
        image = "cortexproject/cortex:${Cortex.Version}"

        args = ["-config.file=/local/Cortex.yaml"]

        memory_hard_limit = 256
      }

      meta {
        TARGET = "query-frontend"

        REPLICAS = "3"
      }

      resources {
        cpu = 128
        memory = 256
        memory_max = 256
      }

      template {
        data = <<EOF
${Cortex.YAMLConfig}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/Cortex.yaml"
      }

      template {
        data = <<EOF
${Cortex.Database.Password}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "secrets/DB_PASS"
      }
    }
  }
}