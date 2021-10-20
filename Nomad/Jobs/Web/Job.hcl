job "ingress" {
  datacenters = ["core0site1"]

  type = "service"

  group "proxies" {
    count = 4

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
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

        ports = ["syslog", "dhcp", "tftp", "dns"]
      }

      template {
        data = <<EOF
${GoBetweenCONF}
EOF

        destination = "local/gobetween.toml"
      }

      resources {
        cpu = 300

        memory = 256
        memory_max = 512 
      }
    }
  }
}