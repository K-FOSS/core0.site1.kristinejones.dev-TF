job "cortex-alertmanager" {
  datacenters = ["core0site1"]

  #
  # Cortex Alert Manager
  #
  group "cortex-alertmanager" {
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

      port "alertmanagerha" {
        to = 9094
      }

      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    task "wait-for-configs" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z http.cortex-configs.service.dc1.kjdev 8080; do sleep 1; done"]
      }
    }

    service {
      name = "cortex-alertmanager"
      port = "http"

      task = "cortex-alertmanager"
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
      name = "cortex-alertmanager"
      port = "grpc"

      task = "cortex-alertmanager"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc", "$${NOMAD_ALLOC_INDEX}.grpc"]
    }

    service {
      name = "cortex-alertmanager"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-alertmanager"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "gossip", "$${NOMAD_ALLOC_INDEX}.gossip"]
    }

    service {
      name = "cortex-alertmanager"
      
      port = "alertmanagerha"
      address_mode = "alloc"

      task = "cortex-alertmanager"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "ha", "$${NOMAD_ALLOC_INDEX}.ha"]
    }

    task "cortex-alertmanager" {
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
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=cortex,service=alert-manager"
          }
        }
      }

      meta {
        TARGET = "alertmanager"

        REPLICAS = "3"
      }

      env {
        JAEGER_AGENT_HOST = "http.distributor.tempo.service.kjdev"
        JAEGER_AGENT_PORT = "6831"
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
${Cortex.AlertManager.Config}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/AlertManager.yaml"
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