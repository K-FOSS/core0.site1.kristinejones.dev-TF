job "postgresql-metrics" {
  datacenters = ["core0site1"]

  group "postgresql-exporter-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "metrics" {
        to = 9436
      }
    }

    service {
      name = "postgresql"
      port = "metrics"

      task = "mikrotik-exporter"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics", "$${NOMAD_ALLOC_INDEX}.metrics"]
    }

    task "postgresql-exporter" {
      driver = "docker"

      config {
        image = "kristianfjones/pgexporter-docker:core0"
      }

      env {
        CONFIG_FILE = "/local/Config.yaml"
      }

      template {
        data = <<EOF
${MikroTik.Config}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/Config.yaml"
      }
    }
  }
}