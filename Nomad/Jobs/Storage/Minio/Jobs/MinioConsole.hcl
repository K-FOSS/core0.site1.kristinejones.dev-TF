job "storage-minio-console" {
  datacenters = ["core0site1"]

  group "minio-console" {
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

    service {
      name = "minio"
      port = "http"

      task = "minio-console-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.console"]
    }

    task "minio-console-server" {
      driver = "docker"

      config {
        image = "${Minio.Image.Repo}:${Minio.Image.Tag}"

        memory_hard_limit = 256
      
        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=minio,service=console"
          }
        }
      }

      resources {
        cpu = 128

        memory = 32
        memory_max = 256
      }

      env {

      }
    }
  }
}