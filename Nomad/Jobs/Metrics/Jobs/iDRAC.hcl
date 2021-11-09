job "idrac-metrics" {
  datacenters = ["core0site1"]

  group "idrac-exporter-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "metrics" {
        to = 8080
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
        image = "kvitex/idrac-exporter"
      }

      template {
        data = <<EOH
DEVICE_USER="${iDRAC.Username}"
IDRAC_USER="${iDRAC.Username}"
DEVICE_PASSWORD="${iDRAC.Password}"
IDRAC_PASSWORD="${iDRAC.Password}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }
}