job "ingress-gobetween" {
  datacenters = ["core0site1"]

  group "gobetween-server" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "api" {
        to = 8888
      }

      port "metrics" {
        to = 9284
      }

      port "stun" {
        to = 3478
        
        static = 3478

        host_network = "https"
      }

      port "unifi" {
        to = 8080
        
        static = 8080

        host_network = "https"
      }
    }

    service {
      name = "gobetween"
      port = "api"

      task = "gobetween-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "api"]
    }

    service {
      name = "gobetween"
      port = "metrics"

      task = "gobetween-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics"]
    }

    task "gobetween-server" {
      driver = "docker"

      config {
        image = "kristianfjones/gobetween-docker:core0"

        args = ["--config", "/local/Config.json", "--format", "json"]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=ingress,service=gobetween"
          }
        }
      }

      template {
        data = <<EOF
${GoBetween.Config}
EOF

        destination = "local/Config.json"
      }
    }
  }
}