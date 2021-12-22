job "cortex-queryscheduler" {
  datacenters = ["core0site1"]

  #
  # Cortex Query Scheduler
  #
  group "cortex-query-scheduler" {
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
      name = "cortex"
      port = "http"

      task = "cortex-query-scheduler"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.query-scheduler", "$${NOMAD_ALLOC_INDEX}.http.query-scheduler"]

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

      task = "cortex-query-scheduler"
      address_mode = "alloc"

      tags = ["coredns.enabled", "grpc.query-scheduler", "$${NOMAD_ALLOC_INDEX}.grpc.query-scheduler", "_grpclb._tcp.grpc.query-scheduler"]
    }

    service {
      name = "cortex"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-query-scheduler"

      tags = ["coredns.enabled", "gossip.query-scheduler", "$${NOMAD_ALLOC_INDEX}.gossip.query-scheduler"]
    }

    task "cortex-query-scheduler" {
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

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=cortex,service=query-scheduler"
          }
        }
      }

      meta {
        TARGET = "query-scheduler"

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

        JAEGER_TAGS = "job=cortex,service=query-scheduler"
      }

      resources {
        cpu = 256
        memory = 32
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