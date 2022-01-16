job "brokers-zookeeper-server" {
  datacenters = ["core0site1"]

  group "zookeeper-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 22181
      }
    }

    service {
      name = "zookeeper"
      port = "http"

      task = "zookeeper-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]
    }

    task "zookeeper-server" {
      driver = "docker"

      config {
        image = "${ZooKeeper.Image.Repo}:${ZooKeeper.Image.Tag}"

        memory_hard_limit = 256

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=zookeeper,service=server"
          }
        }
      }

      env {
        ZOOKEEPER_CLIENT_PORT = "2181"

        ZOOKEEPER_TICK_TIME = "2000"
      }

      resources {
        cpu = 128

        memory = 64
        memory_max = 256
      }
    }
  }
}