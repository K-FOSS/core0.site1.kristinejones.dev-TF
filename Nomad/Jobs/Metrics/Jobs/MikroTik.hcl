job "mikrotik-metrics" {
  datacenters = ["core0site1"]

  group "mikrotik-exporter-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "metrics" {
        to = 9436
      }
    }

    service {
      name = "mikrotik"
      port = "metrics"

      task = "mikrotik-exporter"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics", "$${NOMAD_ALLOC_INDEX}.metrics"]
    }

    task "mikrotik-exporter" {
      driver = "docker"

      config {
        image = "nshttpd/mikrotik-exporter:${MikroTik.Version}"

        args = ["-config-file", "/local/Config.yaml"]
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