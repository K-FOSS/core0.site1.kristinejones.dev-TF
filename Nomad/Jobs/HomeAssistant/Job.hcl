job "homeassistant" {
  datacenters = ["core0site1"]

  group "homeassistant-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "nextcloud-redis"
      port = "redis"

      task = "redis"

      address_mode = "alloc"
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }

  group "nextcloud-server" {
    count = 1

    volume "${Volume.name}" {
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

    task "nextcloud-server" {
      driver = "docker"

      volume_mount {
        volume      = "${Volume.name}"
        destination = "/config"
      }

      config {
        image = "homeassistant/home-assistant:${Version}"

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
EOH

        destination = "local/HomeAssistant.yaml"
        env         = true
      }
    }
  }
}