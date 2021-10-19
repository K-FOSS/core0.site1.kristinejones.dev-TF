job "Patroni" {
  datacenters = ["core0site1"]

  group "postgres-database" {
    count = 5

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    update {
      max_parallel = 1
      health_check = "task_states"
      min_healthy_time = "10s"
      healthy_deadline = "3m"
      progress_deadline = "6h"
    }

    restart {
      attempts = 3
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    volume "database-data" {
      type = "csi"
      read_only = false
      source = "${Volume.name}"
      attachment_mode = "file-system"
      access_mode = "multi-node-multi-writer"
    }

    network {
      mode = "cni/nomadcore1"

      port "psql" {
        to = 5432
      }

      port "http" {
        to = 8080
      }
    }

    service {
      name = "patroni-store"
      port = "psql"

      task = "patroni"  
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled"]

      meta {
        id = "$${NOMAD_ALLOC_INDEX}"
      }

      #
      # TODO: PSQL Healthcheck
      #
    }

    service {
      name = "patroni"
      port = "http"

      task = "patroni"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled"]

      meta {
        id = "$${NOMAD_ALLOC_INDEX}"
      }
    }

    task "patroni" {
      driver = "docker"

      user = "0"

      kill_timeout = 300

      config {
        image = "registry.opensource.zalan.do/acid/spilo-13:2.1-p1"

        command = "/local/entry.sh"

        tty = true
        privileged = true

        args = []

        devices = [
          {
            host_path = "/dev/watchdog"
            container_path = "/dev/watchdog"
          }
        ]
      }

      volume_mount {
        volume = "database-data"
        destination = "/data"
      }

      template {
        data = <<EOF
${Patroni.YAMLConfig}
EOF

        destination = "local/Patroni.yaml"

        change_mode = "signal"
        change_signal = "SIGHUP"
      }

      # Entrypoint Script
      template {
        data = <<EOF
${Patroni.Entryscript}
EOF

        destination = "local/entry.sh"

        perms = "777"

        change_mode = "signal"
        change_signal = "SIGHUP"
      }

      resources {
        cpu = 1024
        memory = 1024

        memory_max = 2048
      }
    }
  }
}