job "mesh-meshery-adapter-consul" {
  datacenters = ["core0site1"]

  group "meshery-server" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 10002
      }
    }

    service {
      name = "meshery"
      port = "http"

      task = "meshery-consul-adapter"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.consul.adapter", "consul.adapter"]
    }

    task "meshery-consul-adapter" {
      driver = "docker"

      config {
        image = "layer5/meshery-consul:edge-latest"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=meshery,service=consul-adapter"
          }
        }
      }

      env {
        #
        # Database
        #
        MESHERY_SERVER = "http://http.server.meshery.service.dc1.kjdev:8080"
      }
    }
  }
}