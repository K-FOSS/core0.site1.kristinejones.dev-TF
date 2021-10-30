job "machine-static" {
  datacenters = ["core0site1"]

  group "tftp" {
    count = 3

    network {
      mode = "cni/nomadcore1"

      port "tftp" { 
        to = 8069
      }

      port "http" { 
        to = 8080
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

      tags = ["coredns.enabled"]
    }

    service {
      name = "http-cont"
      port = "http"

      task = "http-server"
      address_mode = "alloc"

      tags = ["coredns.enabled"]
    }

    task "volume-prepare" {
      driver = "docker"

      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      volume_mount {
        volume      = "tftp-data"
        destination = "/data"
      }

      config {
        image = "alpine:3.14.2"

        command = "/local/entry.sh"
      }

      # Entrypoint Script
      template {
        data = <<EOF
${EntryScript}
EOF

        destination = "local/entry.sh"

        perms = "777"
      }
    }

    task "tftp-server" {
      driver = "docker"

      volume_mount {
        volume      = "tftp-data"
        destination = "/data"
      }

      config {
        image = "kristianfoss/programs-tftpd:tftpd-stable-scratch"

        args = ["-E", "0.0.0.0", "8069", "tftpd", "-u", "user", "-c", "/data"]

        memory_hard_limit = 500
      }

      resources {
        cpu = 128
        memory = 128
        memory_max = 500
      }
    }

    task "http-server" {
      driver = "docker"

      volume_mount {
        volume      = "tftp-data"
        destination = "/data"
        read_only = true
      }

      config {
        image = "kristianfjones/caddy-core-docker:vps1"

        args = ["caddy", "run", "--config", "/local/caddyfile.json"]

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=tinkerbell,service=static-http"
          }
        }
      }

      template {
        data = <<EOF
${Caddy.Config}
EOF

        destination = "local/caddyfile.json"
      }

      resources {
        cpu = 128
        memory = 128
      }
    }
  }
}