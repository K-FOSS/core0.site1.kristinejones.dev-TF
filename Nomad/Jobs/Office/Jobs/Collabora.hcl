job "collabora" {
  datacenters = ["core0site1"]

  group "collabora" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 9980
      }
    }

    service {
      name = "collabora"
      port = "http"

      task = "collabora-online-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]
    }

    task "collabora-online-server" {
      driver = "docker"

      config {
        image = "collabora/code:latest"

        memory_hard_limit = 256
      }

      resources {
        cpu = 64

        memory = 32
        memory_max = 256
      }

      env {
        domain = "office\\.kristianjones\\.dev"

        username = "admin"
        password = "admin"
      }
    }
  }
}