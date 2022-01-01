job "network-dns-networkdns" {
  datacenters = ["core0site1"]

  group "networkdns-coredns-server" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "dns" {
        to = 8055

        static = 8055

        host_network = "dns"
      }

      port "health" {
        to = 8080
      }
    }

    service {
      name = "dns"
      port = "dns"

      task = "networkdns-coredns-server"
      address_mode = "alloc"

      tags = ["dns.network"]

      check {
        name = "CoreDNS DNS healthcheck"

        address_mode = "alloc"
        port = "health"
        type = "http"
        path = "/health"
        interval = "20s"
        timeout  = "5s"
        
        check_restart {
          limit = 3
          grace = "60s"
          ignore_warnings = false
        }
      }
    }

    task "networkdns-coredns-server" {
      driver = "docker"

      config {
        image = "kristianfjones/coredns-docker:core0"

        args = ["-conf=/local/Corefile"]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=dns,service=networkdns"
          }
        }
      }

      template {
        data = <<EOF
${CoreFile}
EOF

        destination = "local/Corefile"
      }

      template {
        data = <<EOF
${PluginsConfig}
EOF

        destination = "local/plugin.cfg"
      }

      resources {
        cpu = 64
        memory = 64
        memory_max = 64
      }
    }
  }
}