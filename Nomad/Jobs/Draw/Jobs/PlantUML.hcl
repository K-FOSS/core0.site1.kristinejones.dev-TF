job "plantuml" {
  datacenters = ["core0site1"]

  group "plantuml-server" {
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
      name = "plantuml"
      port = "http"

      task = "plantuml-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]
    }

    task "plantuml-server" {
      driver = "docker"

      config {
        image = "plantuml/plantuml-server:tomcat"
      }

      resources {
        cpu = 512
        memory = 812
        memory_max = 812
      }

      env {
        PLANTUML_STATS = "on"
      }
    }
  }
}