job "performance-sentry-server" {
  datacenters = ["core0site1"]

  group "sentry-server" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" { 
        to = 8443
      }
    }

    service {
      name = "sentry"
      port = "https"

      task = "sentry-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.server"]
    }

    task "sentry-server" {
      driver = "docker"

      config {
        image = "${Sentry.Image.Repo}/sentry:${Sentry.Image.Tag}"
      }

      resources {
        cpu = 512
        memory = 256
        memory_max = 1024
      }

      env {
      }
    }
  }
}