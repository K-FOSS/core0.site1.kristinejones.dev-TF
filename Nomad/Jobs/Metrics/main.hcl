job "metrics" {
  datacenters = ["core0site1"]

  group "cortex" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "memcached" { 
        static = 11211
      }

%{ for TARGET in TARGETS ~}
      port "${replace("${TARGET.name}", "-", "")}_http" { }

      port "${replace("${TARGET.name}", "-", "")}_grpc" { }
%{ endfor ~}
    }

%{ for TARGET in TARGETS ~}
    service {
      name = "cortex-${TARGET.name}-http-cont"
      port = "${replace("${TARGET.name}", "-", "")}_http"

      task = "cortex-${TARGET.name}"

      address_mode = "alloc"
    }

    service {
      name = "cortex-${TARGET.name}-grpc-cont"
      port = "${replace("${TARGET.name}", "-", "")}_grpc"

      task = "cortex-${TARGET.name}"

      address_mode = "alloc"
    }
%{ endfor ~}

    service {
      name = "cortex-memcached"
      port = "memcached"

      task = "cortex-memcached"

      address_mode = "alloc"
    }

    task "cortex-memcached" {
      driver = "docker"

      config {
        image = "memcached:1.6"
      }


    }


%{ for TARGET in TARGETS ~}
    task "cortex-${TARGET.name}" {
      driver = "docker"

      restart {
        attempts = 5
        delay    = "60s"
      }

      config {
        image = "cortexproject/cortex:v1.10.0"

        args = ["-config.file=/local/Cortex.yaml"]
      }

      env {
        TARGET = "${TARGET.name}"
        TARGET_RPL = "${replace("${TARGET.name}", "-", "")}"
      }

      meta {
        TARGET = "${TARGET.name}"
        TARGET_RPL = "${replace("${TARGET.name}", "-", "")}"

        GRPC_PORT_LABEL = "${replace("${TARGET.name}", "-", "")}_grpc"
        HTTP_PORT_LABEL = "${replace("${TARGET.name}", "-", "")}_http"
      }

      template {
        data = <<EOF
${CORTEX.CORTEX_CONFIG}
EOF

        destination = "local/Cortex.yaml"
      }
    }
%{ endfor ~}

    task "prometheus" {
      driver = "docker"

      restart {
        attempts = 5
        delay    = "60s"
      }

      config {
        image = "prom/prometheus:v2.30.0"

        args = ["--config.file=/local/prometheus.yaml", "--enable-feature=exemplar-storage"]
      }

      template {
        data = <<EOF
${PROMETHEUS_CONFIG}
EOF

        destination = "local/prometheus.yaml"
      }
    }

  }
}