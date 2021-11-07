job "pomerium-databroker" {
  datacenters = ["core0site1"]

  group "pomerium-databroker-cache" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "pomerium-redis-cont"
      port = "redis"

      task = "redis"
      address_mode = "alloc"

      tags = ["coredns.enabled"]
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6-alpine3.14"

        command = "redis-server"

        args = ["/local/redis.conf"]
      }

      template {
        data = <<EOF
port 0
tls-port 6379

tls-cert-file /local/cert.pem
tls-key-file /local/cert.key

tls-ca-cert-file /local/ca.pem
EOF

        destination = "local/redis.conf"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${TLS.Redis.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.Redis.Key}
EOF

        destination = "local/cert.key"
      }
    }
  }

  group "pomerium-databroker" {
    count = 3

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 443
      }
    }

    service {
      name = "pomerium"
      port = "https"

      task = "pomerium-databroker-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https.databroker"]
    }

    task "pomerium-databroker-server" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "60s"
      }

      config {
        image = "pomerium/pomerium:${Version}"

        args = ["-config=/local/Pomerium.yaml"]

        labels {
          job = "pomerium"
          service = "databroker"
        }
      }

      meta {
        SERVICE = "databroker"
      }

      template {
        data = <<EOF
${Config}
EOF

        destination = "local/Pomerium.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${Service.TLS.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${Service.TLS.Key}
EOF

        destination = "local/cert.key"
      }

      #
      # TLS & mTLS to end services
      #

      #
      # TODO: Get Grafana checking Pomerium client Certs
      #
      template {
        data = <<EOF
${TLS.Grafana.CA}
EOF

        destination = "secrets/TLS/GrafanaCA.pem"
      }

      #
      # HomeAssistant
      #
      # TODO: Proper mTLS
      #
      template {
        data = <<EOF
${TLS.HomeAssistant.CA}
EOF

        destination = "secrets/TLS/HomeAssistantCA.pem"
      }

      resources {
        cpu = 800
        memory = 256
      }
    }
  }

}