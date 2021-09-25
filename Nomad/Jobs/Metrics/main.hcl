job "metrics" {
  datacenters = ["core0site1"]

  group "cortex" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "memcached" { 
        static = 11211
      }

%{ for Target in Cortex.Targets ~}
      port "${replace("${Target.name}", "-", "")}_http" { }

      port "${replace("${Target.name}", "-", "")}_grpc" { }
%{ endfor ~}
    }

%{ for Target in Cortex.Targets ~}
    service {
      name = "cortex-${Target.name}-http-cont"
      port = "${replace("${Target.name}", "-", "")}_http"

      task = "cortex-${Target.name}"

      address_mode = "alloc"
    }

    service {
      name = "cortex-${Target.name}-grpc-cont"
      port = "${replace("${Target.name}", "-", "")}_grpc"

      task = "cortex-${Target.name}"

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


%{ for Target in Cortex.Targets ~}
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
%{ endfor ~}

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

  group "loki" {
    count = 1

    network {
      mode = "cni/nomadcore1"
    }

  }
}