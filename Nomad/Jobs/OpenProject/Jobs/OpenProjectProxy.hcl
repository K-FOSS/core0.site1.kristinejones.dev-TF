job "openproject-proxy" {
  datacenters = ["core0site1"]


  group "openproject-proxy" {

    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 8080
      }
    }

    task "wait-for-opserver" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z https.server.openproject.service.dc1.kjdev 8080; do sleep 1; done"]
      }
    }

    service {
      name = "openproject"
      port = "http"

      task = "openproject-proxy"

      address_mode = "alloc"

      tags = ["coredns.enabled", "proxy"]
    }

    task "openproject-proxy" {
      driver = "docker"

      user = "101"

      config {
        image = "openproject/community:${Version}"

        command = "./docker/prod/proxy"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=openproject,service=proxy"
          }
        }
      }

      env {
        APP_HOST = "http.server.openproject.service.dc1.kjdev"
      }
    }
  }
}