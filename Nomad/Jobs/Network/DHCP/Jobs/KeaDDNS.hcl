job "network-dhcp-keaddns" {
  datacenters = ["core0site1"]

  group "dhcp" {
    count = 4

    network {
      mode = "cni/nomadcore1"

      port "dhcp" {
        to = 67
      }

      port "metrics" {
        to = 9547
      }

      port "controlagent" {
        to = 8000
      }
    }

    service {
      name = "keadhcp"
      port = "dhcp"

      task = "kea-dhcp-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "dns.ddns"]
    }

    task "kea-ddns-server" {
      driver = "docker"

      config {
        image = "kristianfjones/kea:vps1-core"
        Entrypoint = ["/usr/sbin/kea-dhcp4"]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=dhcp,service=kea-ddns"
          }
        }
      }

      #
      # DHCP Config
      #

      # DDNS
      template {
        data = <<EOF
${DDNS.Config}
EOF

        destination = "local/DDNS.jsonc"
      }

      resources {
        cpu = 32
        memory = 32
        memory_max = 64
      }
    }
  }
}