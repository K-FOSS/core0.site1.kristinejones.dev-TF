job "metrics" {
  datacenters = ["core0site1"]

  group "cortex" {
    count = 1

    network {
      mode = "bridge"

      port "memcached" { 
        static = 11211
      }

%{ for TARGET in TARGETS ~}
      port "${replace("${TARGET.name}", "-", "")}_http" { }

      port "${replace("${TARGET.name}", "-", "")}_grpc" { }
%{ endfor ~}
    }

    task "cortex-memcached" {
      driver = "docker"

      config {
        image = "memcached:1.6"

        network_mode = "bridge"

        hostname = "redis"
      }

      service {
        name = "cortex-memcached"
        port = "memcached"

        address_mode = "driver"
      }
    }


%{ for TARGET in TARGETS ~}
    task "cortex-${TARGET.name}" {
      driver = "docker"

      restart {
        attempts = 5
        delay    = "60s"
      }

      service {
        name = "cortex-${TARGET.name}-http-cont"
        port = "${replace("${TARGET.name}", "-", "")}_http"

        address_mode = "driver"
      }

      service {
        name = "cortex-${TARGET.name}-grpc-cont"
        port = "${replace("${TARGET.name}", "-", "")}_grpc"

        address_mode = "driver"
      }

      config {
        image = "cortexproject/cortex:v1.10.0"

        args = ["-config.file=/local/Cortex.yaml"]

        network_mode = "bridge"
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


  }
}