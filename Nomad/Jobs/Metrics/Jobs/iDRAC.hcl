job "idrac-metrics" {
  datacenters = ["core0site1"]

  group "idrac-exporter-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "metrics" {
        to = 9348
      }
    }

    service {
      name = "idrac"
      port = "metrics"

      task = "idrac-exporter"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics", "$${NOMAD_ALLOC_INDEX}.metrics"]
    }

    task "idrac-exporter" {
      driver = "docker"

      config {
        image = "kristianfjones/idracexporter-docker:core0"

        args = ["-config", "/local/Config.yaml"]
      }

      template {
        data = <<EOF
${iDRAC.Config}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/Config.yaml"
      }
    }
  }
}