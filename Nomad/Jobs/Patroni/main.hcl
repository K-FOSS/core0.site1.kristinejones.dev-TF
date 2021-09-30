job "Patroni" {
  datacenters = ["core0site1"]

  group "postgres-database" {
    count = 5

    spread {
      attribute = "$${node.unique.id}"
      weight    = 100
    }

    update {
      max_parallel      = 1
      health_check      = "checks"
      min_healthy_time  = "10s"
      healthy_deadline  = "3m"
      progress_deadline = "5m"
    }

    restart {
      attempts = 3
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    volume "${Volume.name}" {
      type      = "csi"
      read_only = false
      source    = "${Volume.name}"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    network {
      mode = "cni/nomadcore1"

      port "psql" {
        to = 5432
      }

      port "http" {
      }
    }

    service {
      name = "patroni-store"
      port = "psql"
      address_mode = "alloc"

      task = "patroni"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

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
      address_mode = "alloc"

      task = "patroni"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      meta {
        id = "$${NOMAD_ALLOC_INDEX}"
      }

      check {
        name     = "Patroni healthcheck"

        address_mode = "alloc"
        port     = "http"
        type     = "http"
        path     = "/liveness"
        interval = "20s"
        timeout  = "5s"
        
        check_restart {
          limit           = 3
          grace           = "60s"
          ignore_warnings = false
        }
      }
    }

    task "patroni" {
      driver = "docker"

      user = "101"

      config {
        image = "registry.opensource.zalan.do/acid/spilo-13:2.1-p1"

        command = "/usr/local/bin/patroni"

        args = ["/local/Patroni.yaml"]
      }

      volume_mount {
        volume      = "${Volume.name}"
        destination = "/data"
      }

      template {
        data = <<EOF
${CONFIG}
EOF

        destination = "local/Patroni.yaml"
      }

      resources {
        cpu    = 800
        memory = 256
      }
    }
  }
}