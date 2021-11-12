job "bitwarden" {
  datacenters = ["core0site1"]

  group "bitwarden" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 8443
      }

      port "ws" {
        to = 3012
      }
    }

    service {
      name = "bitwarden"
      port = "https"

      task = "vaultwarden-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https"]
    }

    service {
      name = "bitwarden"
      port = "ws"

      task = "vaultwarden-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "wss"]
    }

    task "vaultwarden-server" {
      driver = "docker"

      config {
        image = "vaultwarden/server:alpine"
      }

      env {
        WEBSOCKET_ENABLED = "true"
        ROCKET_PORT = "8443"
        DATABASE_URL = "postgresql://${Database.Username}:${Database.Password}@${Database.Hostname}:${Database.Port}/${Database.Database}"

        ROCKET_TLS = "{certs=\"/secrets/TLS/server.pem\",key=\"/secrets/TLS/server.key\"}"


        DOMAIN = "https://bitwarden.kristianjones.dev"

        SMTP_HOST = "${SMTP.Server}"
        SMTP_PORT = "${SMTP.Port}"
        SMTP_FROM = "${SMTP.Username}"
        SMTP_SSL = "true"

        SMTP_USERNAME = "${SMTP.Username}"
        SMTP_PASSWORD = "${SMTP.Password}"
      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 128
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/TLS/CA.pem"
      }

      template {
        data = <<EOF
${TLS.Server.Cert}
EOF

        destination = "secrets/TLS/server.pem"
      }

      template {
        data = <<EOF
${TLS.Server.Key}
EOF

        destination = "secrets/TLS/server.key"
      }
    }
  }
}