job "cortex-storegateway" {
  datacenters = ["core0site1"]

  #
  # Cortex Store Gateway
  #
  group "cortex-store-gateway" {
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

      task = "cortex-store-gateway"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.store-gateway", "$${NOMAD_ALLOC_INDEX}.http.store-gateway"]
    }

    service {
      name = "cortex"
      port = "grpc"

      task = "cortex-store-gateway"
      address_mode = "alloc"

      tags = ["coredns.enabled", "grpc.store-gateway", "$${NOMAD_ALLOC_INDEX}.grpc.store-gateway", "_grpclb._tcp.grpc.store-gateway"]
    }

    service {
      name = "cortex"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-store-gateway"

      tags = ["coredns.enabled", "gossip.store-gateway", "$${NOMAD_ALLOC_INDEX}.gossip.store-gateway"]
    }

    task "cortex-store-gateway" {
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

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=cortex,service=store-gateway"
          }
        }
      }

      meta {
        TARGET = "store-gateway"

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

        JAEGER_TAGS = "job=cortex,service=store-gateway"
      }

      resources {
        cpu = 256

        memory = 256
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