job "cortex-compactor" {
  datacenters = ["core0site1"]

  #
  # Cortex Distributor
  #
  group "cortex-compactor" {
    count = 6

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
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    service {
      name = "cortex"
      port = "http"

      task = "cortex-compactor"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.compactor", "$${NOMAD_ALLOC_INDEX}.http.compactor"]
    }

    service {
      name = "cortex"
      port = "grpc"

      task = "cortex-compactor"
      address_mode = "alloc"

      tags = ["coredns.enabled", "grpc.compactor", "$${NOMAD_ALLOC_INDEX}.grpc.compactor", "_grpclb._tcp.grpc.compactor"]
    }

    service {
      name = "cortex"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-compactor"

      tags = ["coredns.enabled", "gossip.compactor", "$${NOMAD_ALLOC_INDEX}.gossip.compactor"]
    }

    task "cortex-compactor" {
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

        memory_hard_limit = 2048

        mount {
          type = "tmpfs"
          target = "/tsdb"
          readonly = false
          tmpfs_options = {
            size = 124000000
          }
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=cortex,service=compactor"
          }
        }
      }

      meta {
        TARGET = "compactor"

        REPLICAS = "3"
      }

      env {
        #
        # Tracing
        #
        JAEGER_AGENT_HOST = "http.distributor.tempo.service.kjdev"
        JAEGER_AGENT_PORT = "6831"

        JAEGER_SAMPLER_TYPE = "const"
        JAEGER_SAMPLER_PARAM = "1"

        JAEGER_TAGS = "job=cortex,service=compactor"
        
      }

      resources {
        cpu = 256

        memory = 256
        memory_max = 2048
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