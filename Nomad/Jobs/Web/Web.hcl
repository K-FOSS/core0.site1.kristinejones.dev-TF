job "ingress" {
  datacenters = ["core0site1"]

  type = "service"

  constraint {
    operator  = "distinct_hosts"
    value     = "true"
  }

  group "proxies" {
    count = 4

    network {
      mode = "bridge"

      port "https" {
        static = 8443

        to = 8443
      }

      port "http" {
        to = 8080
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

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
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

    service {
      name = "ingressweb-http-cont"
      port = "http"

      task = "web"

      address_mode = "alloc"
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