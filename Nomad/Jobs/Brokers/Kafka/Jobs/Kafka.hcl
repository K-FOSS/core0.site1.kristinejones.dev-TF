job "brokers-kafka-server" {
  datacenters = ["core0site1"]

  group "kafka-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 29092
      }
    }

    service {
      name = "kafka"
      port = "http"

      task = "kafka-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]
    }

    task "kafka-server" {
      driver = "docker"

      config {
        image = "${Kafka.Image.Repo}:${Kafka.Image.Tag}"

        memory_hard_limit = 256

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=kafka,service=server"
          }
        }
      }

      env {
        #
        # Clustering
        #
        KAFKA_BROKER_ID = "1"

        KAFKA_ZOOKEEPER_CONNECT = "http.zookeeper.service.kjdev:2181"
        KAFKA_ADVERTISED_LISTENERS = "PLAINTEXT://http.kafka.service.kjdev:9092,PLAINTEXT_HOST://localhost:29092"
        KAFKA_LISTENER_SECURITY_PROTOCOL_MAP = "PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT"
        KAFKA_INTER_BROKER_LISTENER_NAME = "PLAINTEXT"
        KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR = "1"
      }

      resources {
        cpu = 128

        memory = 64
        memory_max = 256
      }
    }
  }
}