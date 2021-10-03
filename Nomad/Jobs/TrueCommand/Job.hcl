job "truecommand" {
  datacenters = ["core0site1"]

  group "truecommand-server" {
    count = 1

    restart {
      attempts = 3
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 80
      }
    }

    volume "truecommand-data" {
      type      = "csi"
      read_only = false
      source    = "${Volume.name}"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "truecommand-http-cont"
      port = "http"

      task = "truecommand-ui-server"

      address_mode = "alloc"
    }

    task "truecommand-ui-server" {
      driver = "docker"

      volume_mount {
        volume      = "truecommand-data"
        destination = "/data"
      }

      config {
        image = "ixsystems/truecommand:${Version}"
      }

    }
  }
}