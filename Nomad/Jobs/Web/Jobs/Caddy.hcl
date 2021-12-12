job "ingress" {
  datacenters = ["core0site1"]

  type = "service"

  group "proxies" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 443

        static = 443

        host_network = "https"
      }

      port "http" {
        to = 80

        static = 80

        host_network = "https"
      }

      port "http_alt" {
        to = 8080
      }

      port "cortex" {
        to = 9000
      }

      dns {
        servers = [
          "10.1.1.53",
          "172.16.100.25",
          "172.17.0.10",
          "172.18.0.10",
          "172.16.0.1"
        ]
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
      name = "web"
      port = "https"

      task = "web"

      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https"]
    }

    service {
      name = "ingress-webproxy"
      port = "http_alt"

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

    task "web" {
      driver = "docker"

      config {
        image = "kristianfjones/caddy-core-docker:vps1"
      
        args = ["caddy", "run", "--config", "/local/caddyfile.json"]

        ports = ["https"]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=ingress,service=web"
          }
        }
      }

      env {
        CADDY_CLUSTERING_CONSUL_AESKEY = "${Consul.EncryptionKey}"

        JAEGER_SAMPLER_PARAM = "1"
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

      template {
        data = <<EOF
${Harbor.CA}
EOF

        destination = "local/HarborCA.pem"
      }

      template {
        data = <<EOF
${HomeAssistant.CA}
EOF

        destination = "local/HomeAssistant.pem"
      }

      template {
        data = <<EOF
${Bitwarden.CA}
EOF

        destination = "local/Bitwarden.pem"
      }

      resources {
        cpu = 300

        memory = 100
        memory_max = 256
      }
    }
  }
}