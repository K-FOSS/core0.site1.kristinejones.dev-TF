job "ingress" {
  datacenters = ["core0site1"]

  group "proxies" {
    count = 3

    network {
      mode = "bridge"

      port "https" {
        static = 8443
      }
    }

    service {
      name = "ingressweb-cont"
      port = "https"

      task = "web"

      connect {
         sidecar_service {
          proxy {
            upstreams {
              destination_name = "bitwarden-cont"

              local_bind_port = 8085
            }

            upstreams {
              destination_name = "grafana-cont"

              local_bind_port = 8086
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

      env = {
        CADDY_CLUSTERING_CONSUL_AESKEY = "${Consul.EncryptionKey}"
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