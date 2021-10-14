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

      port "http" {
        to = 8080
      }

      port "grpc" {
        to = 8085
      }
    }

    service {
      name = "cortex-${Target.name}-http-cont"
      port = "http"

      task = "cortex-${Target.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    service {
      name = "cortex-${Target.name}-grpc-cont"
      port = "grpc"

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

      resources {
        cpu = ${Target.resources.cpu}
        memory = ${Target.resources.memory}
        memory_max = ${Target.resources.memory_max}
      }

      config {
        image = "cortexproject/cortex:${Cortex.Version}"

        args = ["-config.file=/local/Cortex.yaml"]
      }

      meta {
        TARGET = "${Target.name}"
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

    network {
      mode = "cni/nomadcore1"
    }

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
        
        # Config Replacement
        change_mode = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
${Prometheus.Grafana.CA}
EOF

        destination = "local/GrafanaCA.pem"

        change_mode = "noop"
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

      port "http" {
        to = 8080
      }

      port "grpc" { 
        to = 8085
      }
    }

    service {
      name = "loki-${Target.name}-http-cont"
      port = "http"

      task = "loki-${Target.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    service {
      name = "loki-${Target.name}-grpc-cont"
      port = "grpc"

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

      meta {
        TARGET = "${Target.name}"
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

      port "http" {
        to = 8080
      }

      port "grpc" { 
        to = 8085
      }
    }

    service {
      name = "tempo-${Target.name}-http-cont"
      port = "http"

      task = "tempo-${Target.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    service {
      name = "tempo-${Target.name}-grpc-cont"
      port = "grpc"

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
        image = "grafana/tempo:${Tempo.Version}"

        args = ["-search.enabled=true", "-config.file=/local/Tempo.yaml"]
      }

      meta {
        TARGET = "${Target.name}"
      }

      template {
        data = <<EOF
${Tempo.YAMLConfig}
EOF

        destination = "local/Tempo.yaml"
      }

      template {
        data = <<EOF
overrides:
  "single-tenant":
    search_tags_allow_list:
      - "instance"
    ingestion_rate_strategy: "local"
    ingestion_rate_limit_bytes: 15000000
    ingestion_burst_size_bytes: 20000000
    max_traces_per_user: 10000
    max_global_traces_per_user: 0
    max_bytes_per_trace: 50000
    max_search_bytes_per_trace: 0
    block_retention: 0s
EOF

        destination = "local/overrides.yaml"
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