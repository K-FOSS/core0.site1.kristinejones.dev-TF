job "aaa-headscale-server" {
  datacenters = ["core0site1"]

  group "headscale-server" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" { 
        to = 8443
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
      name = "headscale"
      port = "https"

      task = "headscale-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.server"]
    }

    task "headscale-server" {
      driver = "docker"

      config {
        image = "${HeadScale.Image.Repo}:${HeadScale.Image.Tag}"

        memory_hard_limit = 256

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=headscale,service=server"
          }
        }
      }

      env {

      }

      template {
        data = <<EOF
${HeadScale.Config}
EOF

        destination = "local/HeadScale.yaml"
      }

      resources {
        cpu = 64

        memory = 32
        memory_max = 256
      }
    }
  }
}