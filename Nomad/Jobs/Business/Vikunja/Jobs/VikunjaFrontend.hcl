job "business-vikunja-frontend" {
  datacenters = ["core0site1"]

  group "vikunja" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 80
      }
    }

    service {
      name = "vikunja"
      port = "https"

      task = "vikunja-frontend-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.frontend"]
    }

    task "vikunja-frontend-server" {
      driver = "docker"

      config {
        image = "vikunja/frontend"

        memory_hard_limit = 128
      }

      resources {
        cpu = 32

        memory = 64
        memory_max = 128
      }
    }
  }
}