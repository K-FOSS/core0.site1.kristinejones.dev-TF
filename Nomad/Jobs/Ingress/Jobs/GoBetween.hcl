job "ingress-gobetween" {
  datacenters = ["core0site1"]

  priority = 100

  group "gobetween-server" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 443

        static = 443

        host_network = "https"
      }

      port "http" {
        to = 80

        static = 80

        host_network = "https"
      }

      port "nodehttps" {
        to = 443

        static = 443

        host_network = "node"
      }

      port "nodeminio" {
        to = 9080

        static = 9080

        host_network = "https"
      }

      port "api" {
        to = 8888
      }

      port "metrics" {
        to = 9284
      }

      port "unifi" {
        to = 8080
        
        static = 8080

        host_network = "https"
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