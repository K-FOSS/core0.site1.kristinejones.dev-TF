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

    network {
      mode = "cni/nomadcore1"
    }

    task "collabora-online-server" {
      driver = "docker"

      config {
        image = "collabora/code:latest"
      }

      resources {
        cpu = 1024
        memory = 1024
        memory_max = 1024
      }

      env {
        domain = "office\\.kristianjones\\.dev"

        username = "admin"
        password = "admin"
      }
    }
  }
}