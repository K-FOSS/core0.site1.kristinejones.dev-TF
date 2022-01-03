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

        memory_hard_limit = 2048

        volumes = [
          "local/config.php:/config/www/xbackbone/config.php",
          "local/php.ini:/config/php/php-local.ini"
        ]
      }

      env {
        TZ = "America/Winnipeg"
      }

      resources {
        cpu = 128
        memory = 128
        memory_max = 2048
      }

      template {
        data = <<EOF
${ShareX.Config}
EOF

        destination = "local/config.php"
      }

      template {
        data = <<EOF
  upload_max_filesize = 1024M
  post_max_size = 1024M
EOF

        destination = "local/php.ini"
      }
    }
  }
}