job "plantuml" {
  datacenters = ["core0site1"]

  group "plantuml-server" {
    count = 2

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
      name = "plantuml"
      port = "http"

      task = "plantuml-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]
    }

    task "plantuml-server" {
      driver = "docker"

      config {
        image = "registry.kristianjones.dev/cache/plantuml/plantuml-server:tomcat"

        memory_hard_limit = 256
      }

      resources {
        cpu = 64

        memory = 64
        memory_max = 256
      }

      env {
        PLANTUML_STATS = "on"
      }
    }
  }
}