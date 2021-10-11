job "homeassistant" {
  datacenters = ["core0site1"]

  group "homeassistant-server" {
    count = 1

    volume "hassio-data" {
      type      = "csi"
      read_only = false
      source    = "${Volume.name}"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 8443
      }
    }

    service {
      name = "homeassistant-https-cont"
      port = "https"

      task = "nextcloud-server"

      address_mode = "alloc"
    }

    task "volume-prepare" {
      driver = "docker"

      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      volume_mount {
        volume      = "hassio-data"
        destination = "/config"
      }

      config {
        image = "alpine:3.14.2"

        command = "/local/entry.sh"
      }

      # Entrypoint Script
      template {
        data = <<EOF
${PrepareScript}
EOF

        destination = "local/entry.sh"

        perms = "777"
      }
    }

    task "homeassistant-server" {
      driver = "docker"

      volume_mount {
        volume      = "hassio-data"
        destination = "/config"
      }

      config {
        image = "ghcr.io/home-assistant/home-assistant:${Version}"

        privileged = true

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }

      resources {
        cpu    = 1200
        memory = 600
      }
    
      env {

      }

      template {
        data = <<EOH
${SecretsYAML}
EOH

        destination = "local/secrets.yaml"
        env         = true
      }

      template {
        data = <<EOH
${MQTT.Connection.CA}
EOH

        destination = "secrets/MQTTCA.pem"
        env         = true
      }
    }
  }
}