job "business-vikunja-api" {
  datacenters = ["core0site1"]

  group "vikunja" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 3456
      }
    }

    service {
      name = "vikunja"
      port = "https"

      task = "vikunja-api-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.api"]
    }

    task "vikunja-api-server" {
      driver = "docker"

      config {
        image = "vikunja/api"

        entrypoint = ["/app/vikunja/vikunja"]

        args = ["-c", "/local/Config.yaml"]
      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 128
      }

      template {
        data = <<EOF
${Vikunja.Config}
EOF

        destination = "local/Config.yaml"

        change_mode = "signal"
        change_signal = "SIGUSR1"
      }
    }
  }
}