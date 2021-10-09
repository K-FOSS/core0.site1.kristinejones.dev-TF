job "machine-static" {
  datacenters = ["core0site1"]

  group "tftp" {
    count = 3

    network {
      mode = "cni/nomadcore1"

      port "tftp" { 
        to = 8069
      }
    }

    volume "tftp-data" {
      type      = "csi"
      read_only = false
      source    = "${Volume.name}"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "tftp-cont"
      port = "tftp"

      task = "tftp-server"

      address_mode = "alloc"
    }

    task "tftp-server" {
      driver = "docker"

      volume_mount {
        volume      = "tftp-data"
        destination = "/data"
      }

      config {
        image = "kristianfoss/programs-tftpd:tftpd-stable-scratch"

        args = ["-E", "0.0.0.0", "8069", "tftpd", "-u", "user", "-c", "/data", "-vvv"]
      }
    }
  }
}