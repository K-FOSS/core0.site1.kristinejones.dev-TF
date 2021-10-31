job "draw-io" {
  datacenters = ["core0site1"]

  group "draw-io" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 8080
      }
    }

    service {
      name = "drawio"
      port = "http"

      task = "drawio-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]
    }

    task "drawio-server" {
      driver = "docker"

      config {
        image = "jgraph/drawio:${Version}"
      }

      resources {
        cpu = 64
        memory = 64
        memory_max = 128
      }
    }
  }
}