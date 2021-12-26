job "logs" {
  datacenters = ["core0site1"]

  group "vector" {
    count = 2

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

        static = 514

        host_network = "node"
      }

      port "api" {
        to = 8080
      }
    }

    service {
      name = "vector"
      port = "api"

      task = "vector"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "api"]

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

    service {
      name = "vector"
      port = "syslog"

      task = "vector"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "syslog"]

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

        memory_hard_limit = 512
      }

      env {
        VECTOR_CONFIG = "local/vector.yaml"
      }

      resources {
        cpu = 64

        memory = 128
        memory_max = 512
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