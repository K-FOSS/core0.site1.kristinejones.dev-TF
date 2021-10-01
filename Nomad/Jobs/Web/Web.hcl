job "ingress" {
  datacenters = ["core0site1"]

  type = "service"

  group "proxies" {
    count = 4

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 443
      }

      port "syslog" {
        to = 514
      }

      port "dns" {
        to = 53
      }

      port "http" {
        to = 8080
      }

      port "cortex" {
        to = 9000
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

      address_mode = "alloc"
    }

    service {
      name = "ingressweb-http-cont"
      port = "http"

      task = "web"

      address_mode = "alloc"
    }

    service {
      name = "ingressweb-cortex-cont"
      port = "cortex"

      task = "web"

      address_mode = "alloc"
    }

    service {
      name = "ingressweb-syslog-cont"
      port = "syslog"

      task = "gobetween-server"

      address_mode = "alloc"
    }

    task "web" {
      driver = "docker"

      config {
        image        = "kristianfjones/caddy-core-docker:vps1"

        ports = ["https"]
      
        args = ["caddy", "run", "--config", "/local/caddyfile.json"]

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
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

    task "gobetween-server" {
      driver = "docker"

      config {
        image = "yyyar/gobetween:latest"

        command = "/gobetween"
        args = ["-c", "/local/gobetween.toml"]

        ports = ["syslog"]

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }

      template {
        data = <<EOF
${GoBetweenCONF}
EOF

        destination = "local/gobetween.toml"
      }
    }
  }
}