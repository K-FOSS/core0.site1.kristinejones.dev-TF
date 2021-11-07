job "starlink" {
  datacenters = ["core0site1"]

  group "starlink-exporter-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "metrics" {
        to = 9817
      }
    }

    service {
      name = "starlink"
      port = "metrics"

      task = "starlink-exporter"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics", "$${NOMAD_ALLOC_INDEX}.metrics"]
    }

    task "starlink-exporter" {
      driver = "docker"

      config {
        image = "ghcr.io/danopstech/starlink_exporter:${StarLink.Version}"

        args = ["-address=${StarLink.IPAddress}:${StarLink.Port}"]
      }
    }
  }
}