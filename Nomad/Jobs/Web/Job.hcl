job "ingress" {
  datacenters = ["core0site1"]

  type = "service"

  group "proxies" {
    count = 6

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
        to = 53
      }

      port "powerdns" {
        to = 8153
      }

      #
      # DHCP
      #
      port "dhcp" {
        to = 67
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
      name = "ingress-webproxy"
      port = "https"

      task = "web"

      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https"]
    }

    service {
      name = "ingress-webproxy"
      port = "http"

      task = "web"

      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http"]
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
      name = "ingress-l4proxy"
      port = "syslog"

      task = "gobetween-server"

      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "syslog"]
    }

    task "web" {
      driver = "docker"

      config {
        image = "kristianfjones/caddy-core-docker:vps1"
      
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

      template {
        data = <<EOF
${Pomerium.CA}
EOF

        destination = "local/PomeriumCA.pem"
      }

      resources {
        cpu = 300

        memory = 100
        memory_max = 256
      }
    }

    task "gobetween-server" {
      driver = "docker"

      config {
        image = "yyyar/gobetween:latest"

        command = "/gobetween"
        args = ["-c", "/local/gobetween.toml"]

        memory_hard_limit = 512
      }

      template {
        data = <<EOF
${GoBetweenCONF}
EOF

        destination = "local/gobetween.toml"
      }

      resources {
        cpu = 512

        memory = 512
        memory_max = 512
      }
    }
  }
}