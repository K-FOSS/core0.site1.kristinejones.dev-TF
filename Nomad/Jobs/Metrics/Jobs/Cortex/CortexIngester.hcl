job "cortex-ingester" {
  datacenters = ["core0site1"]

  #
  # Cortex Ingester
  #
  group "cortex-ingester" {
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
      name = "cortex"
      port = "http"

      task = "cortex-ingester"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.ingester", "$${NOMAD_ALLOC_INDEX}.http.ingester"]

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

      task = "cortex-ingester"
      address_mode = "alloc"

      tags = ["coredns.enabled", "grpc.ingester", "$${NOMAD_ALLOC_INDEX}.grpc.ingester", "_grpclb._tcp.grpc.ingester"]
    }

    service {
      name = "cortex"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-ingester"

      tags = ["coredns.enabled", "gossip.ingester", "$${NOMAD_ALLOC_INDEX}.gossip.ingester"]
    }

    task "cortex-ingester" {
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

        memory_hard_limit = 1024

        mount {
          type = "tmpfs"
          target = "/tsdb"
          readonly = false
          tmpfs_options = {
            size = 10240000000
          }
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=cortex,service=ingester"
          }
        }
      }

      meta {
        TARGET = "ingester"

        REPLICAS = "3"
      }

      resources {
        cpu = 128

        memory = 128
        memory_max = 1024
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