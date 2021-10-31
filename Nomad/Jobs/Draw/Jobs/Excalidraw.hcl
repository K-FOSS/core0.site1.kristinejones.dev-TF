job "excalidraw" {
  datacenters = ["core0site1"]

  group "excalidraw" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 80
      }
    }

    service {
      name = "excalidraw"
      port = "http"

      task = "excalidraw-web"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]
    }


    task "excalidraw-server" {
      driver = "docker"

      config {
        image = "excalidraw/excalidraw"
      }
    }
  }
}