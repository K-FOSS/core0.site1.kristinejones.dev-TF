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
      name = "cortex-querier"
      port = "http"

      task = "cortex-querier"
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
      name = "cortex-querier"
      port = "grpc"

      task = "cortex-querier"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc", "$${NOMAD_ALLOC_INDEX}.grpc"]
    }

    service {
      name = "cortex-querier"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-querier"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "gossip", "$${NOMAD_ALLOC_INDEX}.gossip"]
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

        memory_hard_limit = 256
      }

      meta {
        TARGET = "querier"

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