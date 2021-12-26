job "communications-mattermost-leader" {
  datacenters = ["core0site1"]

  group "mattermost-leader" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 8080
      }
    }

    service {
      name = "mattermost-leader-http-cont"
      port = "http"

      task = "mattermost-server"
      address_mode = "alloc"

      tags = ["coredns.enabled"]
    }

    task "mattermost-server" {
      driver = "docker"

      user = "0"

      config {
        image = "mattermost/mattermost-team-edition:${Mattermost.Version}"

        entrypoint = ["/mattermost/bin/mattermost"]
        args = ["server", "-c", "/local/config.json"]

        memory_hard_limit = 512

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=mattermost,service=coreserver"
          }
        }
      }
    
      env {
        RUN_SERVER_IN_BACKGROUND = "false"
        MM_NO_DOCKER = "true"
        APP_PORT_NUMBER = "8080"
      }

      resources {
        cpu = 64

        memory = 64
        memory_max = 512
      }

      template {
        data = <<EOF
${Mattermost.Config}
EOF

        destination = "local/config.json"

        change_mode = "noop"
      }
    }
  }
}