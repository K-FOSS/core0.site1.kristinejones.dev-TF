job "cortex-configs" {
  datacenters = ["core0site1"]

  #
  # Cortex Configs
  #
  group "cortex-configs" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080

        host_network = "node"
      }

      port "grpc" {
        to = 8085
      }

      port "gossip" {
        to = 8090
      }

      dns {
        servers = [
          "10.1.1.13",
          "10.1.1.10"
        ]
      }
    }

    service {
      name = "cortex"
      port = "http"

      task = "cortex-configs"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.configs", "$${NOMAD_ALLOC_INDEX}.http.configs"]

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
      name = "cortex"
      port = "grpc"

      task = "cortex-configs"
      address_mode = "alloc"

      tags = ["coredns.enabled", "grpc", "$${NOMAD_ALLOC_INDEX}.grpc", "_grpclb._tcp.grpc.configs"]
    }

    service {
      name = "cortex"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-configs"

      tags = ["coredns.enabled", "gossip.configs", "$${NOMAD_ALLOC_INDEX}.gossip.configs"]
    }

    task "cortex-configs" {
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

        memory_hard_limit = 64
      }

      meta {
        TARGET = "configs"

        REPLICAS = "3"
      }

      resources {
        cpu = 32
        memory = 32
        memory_max = 64
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