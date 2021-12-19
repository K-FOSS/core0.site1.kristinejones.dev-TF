job "search-opensearch-server" {
  datacenters = ["core0site1"]

  group "opensearch-server" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 9200
      }

      port "apm" {
        to = 9600
      }

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    service {
      name = "opensearch"
      port = "https"

      task = "opensearch-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.server", "$${NOMAD_ALLOC_INDEX}.https.server"]
    }

    task "opensearch-server" {
      driver = "docker"

      config {
        image = "${OpenSearch.Image.Repo}/opensearch:${OpenSearch.Image.Version}"

        entrypoint = ["/usr/share/opensearch/bin/opensearch"]
        args = []

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=opensearch,service=server$${NOMAD_ALLOC_INDEX}"
          }
        }
      }

      resources {
        cpu = 1024

        memory = 1024
      }

      env {
        OPENSEARCH_JAVA_OPTS = "-Xms512m -Xmx512m"

        OPENSEARCH_PATH_CONF = "/local/Config.yaml"
      }

      template {
        data = <<EOF
${OpenSearch.Config}
EOF

        destination = "local/Config.yaml"
      }
    }
  }
}