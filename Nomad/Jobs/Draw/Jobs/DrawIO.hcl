job "draw-io" {
  datacenters = ["core0site1"]

  group "draw-io" {
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

        memory_hard_limit = 256
      }

      resources {
        cpu = 64

        memory = 64
        memory_max = 256
      }

      env {
        #
        # Core
        #
        DRAWIO_BASE_URL = "https://drawio.int.site1.kristianjones.dev"
        DRAWIO_SELF_CONTAINED = "1"

        #
        # GitLab
        #
        DRAWIO_GITLAB_URL = "https://gitlab.int.site1.kristianjones.dev"
        DRAWIO_GITLAB_ID = ""
        DRAWIO_GITLAB_SECRET = ""

        #
        # PlantUML
        #
        PLANTUML_URL = "http://http.plantuml.service.dc1.kjdev:8080"

        #
        # Cache
        #
        DRAWIO_MEMCACHED_ENDPOINT = "cache.drawio.service.dc1.kjdev:11211"

      }
    }
  }
}