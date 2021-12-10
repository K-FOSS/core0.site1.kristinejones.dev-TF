job "business-readflow-api" {
  datacenters = ["core0site1"]

  group "readflow-api" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 8080
      }
    }

    service {
      name = "readflow"
      port = "https"

      task = "readflow-api-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.api"]
    }

    task "readflow-api-server" {
      driver = "docker"

      config {
        image = "ncarlier/readflow:latest"
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

        destination = "local/config.yaml"

        change_mode = "signal"
        change_signal = "SIGUSR1"
      }
    }
  }
}