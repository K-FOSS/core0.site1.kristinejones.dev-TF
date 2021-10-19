job "ingress" {
  datacenters = ["core0site1"]

  type = "service"

  group "proxies" {
    count = 4

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 443
      }

      port "syslog" {
        to = 514
      }

      port "dns" {
        static = 53

        to = 53
      }

      port "powerdns" {
        static = 8153

        to = 8153
      }

      #
      # DHCP
      #
      port "dhcp" {
        static = 67

        to = 67
      }

      #
      # TFTP
      #
      port "tftp" {
        static = 69

        to = 69
      }

      port "http" {
        to = 8080
      }

      port "cortex" {
        to = 9000
      }
    }

    #
    # Caddy Reverse Proxy (TCP, TLS, mTLS)
    #
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

    #
    # GoBetween Load Balancer
    #

    service {
      name = "ingressweb-syslog-cont"
      port = "syslog"

      task = "gobetween-server"

      address_mode = "alloc"
    }

    service {
      name = "gobetween-tftp-cont"
      port = "tftp"

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

      template {
        data = <<EOF
${Pomerium.CA}
EOF

        destination = "local/PomeriumCA.pem"
      }
    }

    task "gobetween-server" {
      driver = "docker"

      config {
        image = "yyyar/gobetween:latest"

        command = "/gobetween"
        args = ["-c", "/local/gobetween.toml"]

        ports = ["syslog", "dhcp", "tftp", "dns"]

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