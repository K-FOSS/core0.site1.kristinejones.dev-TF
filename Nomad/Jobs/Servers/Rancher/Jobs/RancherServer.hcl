job "servers-rancher-server" {
  datacenters = ["core0site1"]

  group "rancher-server" {
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
      name = "rancher"
      port = "http"

      task = "rancher-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https"]
    }

    task "collabora-online-server" {
      driver = "docker"

      config {
        image = "collabora/code:latest"

        privileged = true
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