job "metrics" {
  datacenters = ["core0site1"]

  group "cortex" {
    count = 1

    network {
      mode = "bridge"

%{ for TARGET in TARGETS ~}
      port "${replace("${TARGET.name}", "-", "")}_http" { }

      port "${TARGET.name}_grpc" { }
%{ endfor ~}
    }


%{ for TARGET in TARGETS ~}
    task "cortex-${TARGET.name}" {
      driver = "docker"

      service {
        name = "cortex-${TARGET.name}-http-cont"
        port = "${TARGET.name}_http"

        address_mode = "driver"
      }

      service {
        name = "cortex-${TARGET.name}-grpc-cont"
        port = "${TARGET.name}_grpc"

        address_mode = "driver"
      }

      config {
        image = "cortexproject/cortex:v1.10.0"

        args = ["-config.file=/local/Cortex.yaml"]

        network_mode = "bridge"
      }

      meta {
        target = "${TARGET.name}"
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