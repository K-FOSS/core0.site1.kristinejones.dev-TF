job "ingress" {
  datacenters = ["core0site1"]

  group "proxies" {
    count = 3

    network {
      mode = "bridge"

      port "http" {
        static = 8443
      }
    }

    service {
      name = "ingressweb-cont"
      port = "http"

      task = "web"

      connect {
         sidecar_service {
          proxy {
            upstreams {
              destination_name = "bitwarden-cont"
            }
          }
        }
      }
    }

    task "web" {
      driver = "docker"

      config {
        image        = "kristianfjones/caddy-core-docker:vps1"
      
        args = ["caddy", "run", "--config", "/local/caddyfile.json"]
      }

      template {
        data = <<EOF
${CADDYFILE}
EOF

        destination = "local/caddyfile.json"
      }
    }
  }
}