job "cache-ingress" {
  datacenters = ["core0site1"]

  group "cache-web" {
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

      port "healthcheck" {
        to = 8080
      }

      port "metrics" {
        to = 8080
      }
    }

    service {
      name = "cache-web"
      port = "http"

      task = "web"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http"]
    }

    task "web" {
      driver = "docker"

      config {
        image = "kristianfjones/caddy-core-docker:vps1"

        args = ["caddy", "run", "--config", "/local/caddyfile.json"]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=cache,service=web"
          }
        }
      }

      template {
        data = <<EOF
${Caddyfile}
EOF

        destination = "local/caddyfile.json"
      }
    }
  }
}

