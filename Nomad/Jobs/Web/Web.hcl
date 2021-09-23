job "ingress" {
  datacenters = ["core0site1"]

  type = "service"

  constraint {
    operator  = "distinct_hosts"
    value     = "true"
  }

  group "proxies" {
    network {
      mode = "bridge"

      port "https" {
        static = 8443

        to = 8443
      }

      #
      # CoTurn
      #

      port "turn" { 
        static = 3478
        to = 3478
      }

      port "stun" { }

      port "metrics" {
        static = 9641
      }

      port "cli" { }

      port "redis" {
        static = 6379
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
              destination_name = "authentik-cont"

              local_bind_port = 8087
            }

            upstreams {
              destination_name = "pomerium-cont"

              local_bind_port = 8088
            }
          }
        }
      }
    }

    task "web" {
      driver = "docker"

      config {
        image        = "kristianfjones/caddy-core-docker:vps1"

        ports = ["https"]
      
        args = ["caddy", "run", "--config", "/local/caddyfile.json"]

      }

      env {
        CADDY_CLUSTERING_CONSUL_AESKEY = "${Consul.EncryptionKey}"
      }

      template {
        data = <<EOF
${Caddyfile}
EOF

        destination = "local/caddyfile.json"
      }
    }

    task "coturn-server" {
      driver = "docker"

      config {
        image = "coturn/coturn:edge-alpine"

        args = ["-c", "/local/turnserver.conf", "--prometheus"]

        ports = ["turn"]
      }

      template {
        data = <<EOF
${COTURNCONFIG}
EOF

        destination = "local/turnserver.conf"
      }
    }
  }
}