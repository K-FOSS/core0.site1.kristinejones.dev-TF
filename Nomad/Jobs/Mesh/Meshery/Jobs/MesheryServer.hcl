job "mesh-meshery-server" {
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
        to = 8080
      }
    }

    service {
      name = "meshery"
      port = "http"

      task = "meshery-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http.server"]
    }

    task "meshery-server" {
      driver = "docker"

      config {
        image = "layer5/meshery:edge-latest"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=meshery,service=server"
          }
        }
      }

      env {
        #
        # Database
        #
        PROVIDER_BASE_URLS = "https://meshery.layer5.io"
        ADAPTER_URLS = "http.consul.adapter.meshery.service.dc1.kjdev:10002"

        EVENT = "mesheryLocal"
      }
    }
  }
}