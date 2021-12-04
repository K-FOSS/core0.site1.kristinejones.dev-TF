job "network-enms-server" {
  datacenters = ["core0site1"]

  group "enms" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }
    }

    service {
      name = "enms"
      port = "http"

      task = "kea-dhcp-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "dns.ddns"]
    }

    task "enms-server" {
      driver = "docker"

      config {
        image = "kristianfjones/enms:vps1"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=dhcp,service=kea-ddns"
          }
        }
      }

      env {
        #
        # Database
        #
        DATABASE_URL = ""

        #
        # Secrets
        #

        #
        # Vault
        #
        VAULT_ADDRESS = "http://10.1.1.10:8100"
        VAULT_TOKEN = ""




      }

      #
      # DHCP Config
      #

      # DDNS
      template {
        data = <<EOF
${ENMS.Config}
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