job "search-opensearch-dashboard" {
  datacenters = ["core0site1"]

  group "opensearch-dashboard-server" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 5601
      }
    }

    service {
      name = "opensearch"
      port = "http"

      task = "opensearch-dashboard-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.dashboard", "$${NOMAD_ALLOC_INDEX}.http.dashboard"]
    }

    task "opensearch-dashboard-server" {
      driver = "docker"

      config {
        image = "${OpenSearch.Image.Repo}/opensearch-dashboards:${OpenSearch.Image.Tag}"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=opensearch,service=dashboard"
          }
        }
      }

      env {
        OPENSEARCH_HOSTS = "[\"http://0.https.master.opensearch.service.kjdev:9200\",\"http://1.https.master.opensearch.service.kjdev:9200\",\"http://2.https.master.opensearch.service.kjdev:9200\"]"
      }
    }
  }
}