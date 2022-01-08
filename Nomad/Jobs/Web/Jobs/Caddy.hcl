job "web-caddy" {
  datacenters = ["core0site1"]

  type = "service"

  priority = 100

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

        host_network = "node"
      }

      port "http" {
        to = 80
      }

      port "http_alt" {
        to = 8080
      }

      port "health" {
        to = 8085
      }

      port "cortex" {
        to = 9000
      }

      port "minio" {
        to = 9080
      }

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13",
          "172.18.0.10"
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

      tags = ["coredns.enabled", "https"]

      check {
        name = "Ingress Web HealthCheck"

        address_mode = "alloc"
        port = "health"

        type = "http"
        path = "/health"
        interval = "20s"
        timeout  = "5s"
      }
    }

    service {
      name = "web"
      port = "http"

      task = "web"

      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]

      check {
        name = "Ingress Web HealthCheck"

        address_mode = "alloc"
        port = "health"

        type = "http"
        path = "/health"
        interval = "20s"
        timeout  = "5s"
      }
    }

    service {
      name = "web"
      port = "minio"

      task = "web"

      address_mode = "alloc"

      tags = ["coredns.enabled", "http.minio"]

      check {
        name = "IngressWeb Minio HealthCheck"

        address_mode = "alloc"
        port = "health"

        type = "http"
        path = "/health"
        interval = "20s"
        timeout  = "5s"
      }
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
        ports = ["https"]
      
        args = ["caddy", "run", "--config", "/local/caddyfile.json"]

        memory_hard_limit = 512

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

      resources {
        cpu = 312

        memory = 128
        memory_max = 512
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
${AAA.Teleport.CA}
EOF

        destination = "local/TeleportCA.pem"
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
    }
  }
}