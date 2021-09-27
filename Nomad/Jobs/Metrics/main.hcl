job "metrics" {
  datacenters = ["core0site1"]

  group "loki-memcached" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "memcached" { 
        to = 11211
      }
    }

    service {
      name = "loki-memcached"
      port = "memcached"

      task = "memcached"

      address_mode = "alloc"
    }

    task "memcached" {
      driver = "docker"

      config {
        image = "memcached:1.6"
      }
    }
  }

  group "cortex-memcached" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "memcached" { 
        to = 11211
      }
    }

    service {
      name = "cortex-memcached"
      port = "memcached"

      task = "memcached"

      address_mode = "alloc"
    }

    task "memcached" {
      driver = "docker"

      config {
        image = "memcached:1.6"
      }
    }
  }

%{ for Target in Cortex.Targets ~}
  group "cortex-${Target.name}" {
    count = ${Target.count}

    network {
      mode = "cni/nomadcore1"

      port "${replace("${Target.name}", "-", "")}_http" { }

      port "${replace("${Target.name}", "-", "")}_grpc" { }
    }

    service {
      name = "cortex-${Target.name}-http-cont"
      port = "${replace("${Target.name}", "-", "")}_http"

      task = "cortex-${Target.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    service {
      name = "cortex-${Target.name}-grpc-cont"
      port = "${replace("${Target.name}", "-", "")}_grpc"

      task = "cortex-${Target.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "cortex-${Target.name}" {
      driver = "docker"

      restart {
        attempts = 5
        delay    = "60s"
      }

      config {
        image = "cortexproject/cortex:${Cortex.Version}"

        args = ["-config.file=/local/Cortex.yaml"]
      }

      env {
        TARGET = "${Target.name}"
        TARGET_RPL = "${replace("${Target.name}", "-", "")}"
      }

      meta {
        TARGET = "${Target.name}"
        TARGET_RPL = "${replace("${Target.name}", "-", "")}"

        GRPC_PORT_LABEL = "${replace("${Target.name}", "-", "")}_grpc"
        HTTP_PORT_LABEL = "${replace("${Target.name}", "-", "")}_http"
      }

      template {
        data = <<EOF
${Cortex.YAMLConfig}
EOF

        destination = "local/Cortex.yaml"
      }
    }
  }
%{ endfor ~}

  group "prometheus" {
    count = 1

    task "prometheus" {
      driver = "docker"

      restart {
        attempts = 5
        delay    = "60s"
      }

      config {
        image = "prom/prometheus:${Prometheus.Version}"

        args = ["--config.file=/local/prometheus.yaml", "--enable-feature=exemplar-storage"]
      }

      template {
        data = <<EOF
${Prometheus.YAMLConfig}
EOF

        destination = "local/prometheus.yaml"
      }
    }
  }

  #
  # TODO: Move template over to dedupe Cortex/Loki via mapping over Services.XYZ
  #

%{ for Target in Loki.Targets ~}
  group "loki-${Target.name}" {
    count = ${Target.count}

    network {
      mode = "cni/nomadcore1"

      port "${replace("${Target.name}", "-", "")}_http" { }

      port "${replace("${Target.name}", "-", "")}_grpc" { }
    }

    service {
      name = "loki-${Target.name}-http-cont"
      port = "${replace("${Target.name}", "-", "")}_http"

      task = "loki-${Target.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    service {
      name = "loki-${Target.name}-grpc-cont"
      port = "${replace("${Target.name}", "-", "")}_grpc"

      task = "loki-${Target.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "loki-${Target.name}" {
      driver = "docker"

      restart {
        attempts = 5
        delay    = "60s"
      }

      config {
        image = "grafana/loki:${Loki.Version}"

        args = ["-config.file=/local/Loki.yaml"]
      }

      env {
        TARGET = "${Target.name}"
        TARGET_RPL = "${replace("${Target.name}", "-", "")}"
      }

      meta {
        TARGET = "${Target.name}"
        TARGET_RPL = "${replace("${Target.name}", "-", "")}"

        GRPC_PORT_LABEL = "${replace("${Target.name}", "-", "")}_grpc"
        HTTP_PORT_LABEL = "${replace("${Target.name}", "-", "")}_http"
      }

      template {
        data = <<EOF
${Loki.YAMLConfig}
EOF

        destination = "local/Loki.yaml"
      }
    }
  }
%{ endfor ~}

%{ for Target in Tempo.Targets ~}
  group "tempo-${Target.name}" {
    count = ${Target.count}

    network {
      mode = "cni/nomadcore1"

      port "${replace("${Target.name}", "-", "")}_http" {
        to = 8080
      }

      port "${replace("${Target.name}", "-", "")}_grpc" { 
        to = 8085
      }
    }

    service {
      name = "tempo-${Target.name}-http-cont"
      port = "${replace("${Target.name}", "-", "")}_http"

      task = "tempo-${Target.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    service {
      name = "tempo-${Target.name}-grpc-cont"
      port = "${replace("${Target.name}", "-", "")}_grpc"

      task = "tempo-${Target.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "tempo-${Target.name}" {
      driver = "docker"

      restart {
        attempts = 5
        delay    = "60s"
      }

      config {
        image = "grafana/tempo:${Loki.Version}"

        args = ["-config.file=/local/Tempo.yaml"]
      }

      env {
        TARGET = "${Target.name}"
        TARGET_RPL = "${replace("${Target.name}", "-", "")}"
      }

      meta {
        TARGET = "${Target.name}"
        TARGET_RPL = "${replace("${Target.name}", "-", "")}"

        GRPC_PORT_LABEL = "${replace("${Target.name}", "-", "")}_grpc"
        HTTP_PORT_LABEL = "${replace("${Target.name}", "-", "")}_http"
      }

      template {
        data = <<EOF
${Tempo.YAMLConfig}
EOF

        destination = "local/Tempo.yaml"
      }
    }
  }
%{ endfor ~}

  group "vector" {
    count = 1

    restart {
      attempts = 3
      interval = "10m"
      delay = "30s"
      mode = "fail"
    }

    network {
      mode = "cni/nomadcore1"

      port "syslog" { }

      port "api" { }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    ephemeral_disk {
      size    = 500
      sticky  = true
    }

    service {
      name = "vector-api"
      port = "api"

      task = "vector"

      address_mode = "alloc"

      check {
        port     = "api"
        address_mode = "alloc"

        type     = "http"
        path     = "/health"
        interval = "30s"
        timeout  = "5s"
      }
    }

    service {
      name = "vector-syslog"
      port = "syslog"

      task = "vector"

      address_mode = "alloc"

      check {
        port     = "api"
        address_mode = "alloc"

        type     = "http"
        path     = "/health"
        interval = "30s"
        timeout  = "5s"
      }
    }

    task "vector" {
      driver = "docker"

      config {
        image = "timberio/vector:nightly-alpine"

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }

      env {
        VECTOR_CONFIG = "local/vector.yaml"
        VECTOR_REQUIRE_HEALTHY = "false"
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }

      template {
        destination = "local/vector.yaml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        # overriding the delimiters to [[ ]] to avoid conflicts with Vector's native templating, which also uses {{ }}
        left_delimiter = "[["
        right_delimiter = "]]"
      
        data = <<EOF
${Vector.YAMLConfig}
EOF
      }

      kill_timeout = "30s"
    }
  }
}