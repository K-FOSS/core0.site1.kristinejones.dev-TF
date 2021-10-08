job "ingress" {
  datacenters = ["core0site1"]

  type = "service"

  group "proxies" {
    count = 4

    spread {
      attribute = "$${node.unique.id}"
      weight    = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" {
        static = 443

        to = 443
      }

      port "syslog" {
        to = 514
      }

      port "dns" {
        to = 53
      }

      #
      # DHCP
      #
      port "dhcp" {
        static = 67

        to = 67
      }

      port "http" {
        to = 8080
      }

      port "cortex" {
        to = 9000
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
        image = "kristianfjones/caddy-core-docker:vps1"
      
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

    task "gobetween-server" {
      driver = "docker"

      config {
        image = "yyyar/gobetween:latest"

        command = "/gobetween"
        args = ["-c", "/local/gobetween.toml"]

        ports = ["syslog", "dhcp"]

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