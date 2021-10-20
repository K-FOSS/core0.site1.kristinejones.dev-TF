job "logs" {
  datacenters = ["core0site1"]


  group "vector" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    restart {
      attempts = 3
      interval = "10m"
      delay = "30s"
      mode = "fail"
    }

    network {
      mode = "cni/nomadcore1"

      port "syslog" {
        to = 514
      }

      port "api" {
        to = 8080
      }
    }

    service {
      name = "vector-api"
      port = "api"

      task = "vector"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled"]

      check {
        port = "api"
        address_mode = "alloc"

        type = "http"
        path = "/health"
        interval = "30s"
        timeout = "5s"
      }
    }

    service {
      name = "vector-syslog"
      port = "syslog"

      task = "vector"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled"]

      check {
        port = "api"
        address_mode = "alloc"

        type = "http"
        path = "/health"
        interval = "30s"
        timeout = "5s"
      }
    }

    task "vector" {
      driver = "docker"

      config {
        image = "timberio/vector:${Vector.Version}-alpine"

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }

      env {
        VECTOR_CONFIG = "local/vector.yaml"
      }

      resources {
        cpu = 500
        memory = 1024
      }

      template {
        destination = "local/vector.yaml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        # overriding the delimiters to [[ ]] to avoid conflicts with Vector's native templating, which also uses {{ }}
        left_delimiter = "[["
        right_delimiter = "]]"
      
        data = <<EOF
${Vector.Config}
EOF
      }

      kill_timeout = "30s"
    }
  }
}