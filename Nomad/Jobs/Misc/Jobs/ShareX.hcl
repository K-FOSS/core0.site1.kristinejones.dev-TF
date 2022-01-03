job "misc-sharex-xbackbone" {
  datacenters = ["core0site1"]

  group "sharex" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 80
      }
    }

    service {
      name = "sharex"
      port = "http"

      task = "xbackbone-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]
    }

    task "xbackbone-server" {
      driver = "docker"

      config {
        image = "${ShareX.Image.Repo}:${ShareX.Image.Tag}"

        volumes = [
          "local/config.php:/config/www/xbackbone/config.php"
        ]
      }

      env {
        TZ = "America/Winnipeg"
      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 128
      }

      template {
        data = <<EOF
${ShareX.Config}
EOF

        destination = "local/config.php"
      }
    }
  }
}