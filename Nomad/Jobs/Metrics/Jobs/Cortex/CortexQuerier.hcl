job "cortex-querier" {
  datacenters = ["core0site1"]

  #
  # Cortex Querier
  #
  group "cortex-querier" {
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
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    task "wait-for-memcached" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z memcached.cortex.service.dc1.kjdev 11211; do sleep 1; done"]
      }

      resources {
        cpu = 32
        memory = 32
        memory_max = 32
      }
    }

    service {
      name = "cortex"
      port = "http"

      task = "cortex-querier"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.querier", "$${NOMAD_ALLOC_INDEX}.http.querier"]

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

      task = "cortex-querier"
      address_mode = "alloc"

      tags = ["coredns.enabled", "grpc.querier", "$${NOMAD_ALLOC_INDEX}.grpc.querier", "_grpclb._tcp.grpc.querier"]
    }

    service {
      name = "cortex"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-querier"

      tags = ["coredns.enabled", "gossip.querier", "$${NOMAD_ALLOC_INDEX}.gossip.querier"]
    }

    task "cortex-querier" {
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

        memory_hard_limit = 512

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=cortex,service=querier"
          }
        }
      }

      meta {
        TARGET = "querier"

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

        JAEGER_TAGS = "job=cortex,service=querier"
      }

      resources {
        cpu = 64

        memory = 64
        memory_max = 512
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