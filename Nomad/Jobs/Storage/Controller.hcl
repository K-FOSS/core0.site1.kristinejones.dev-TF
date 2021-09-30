job "storage-controller" {
  datacenters = ["core0site1"]
  type        = "service"

  group "controller" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight    = 100
    }

    update {
      max_parallel      = 1
      health_check      = "task_states"
      min_healthy_time  = "10s"
      healthy_deadline  = "3m"
      progress_deadline = "5m"
    }

    network {
      mode = "bridge"

      port "grpc" { }
    }

    service {
      name = "democraticcsi-controller"
      port = "grpc"

      task = "controller"

      address_mode = "alloc"
    }

    task "controller" {
      driver = "docker"

      config {
        image = "democraticcsi/democratic-csi:latest"

        args = [
          "--csi-version=1.5.0",
          "--csi-name=org.democratic-csi.nfs",
          "--driver-config-file=$${NOMAD_TASK_DIR}/driver-config-file.yaml",
          "--log-level=debug",
          "--csi-mode=controller",
          "--server-socket=/csi-data/csi.sock",
          "--server-address=0.0.0.0",
          "--server-port=$${NOMAD_PORT_grpc}",
        ]

        privileged = true
      }

      csi_plugin {
        id        = "truenas"
        type      = "controller"
        mount_dir = "/csi-data"
      }

      template {
        destination = "$${NOMAD_TASK_DIR}/driver-config-file.yaml"

        data = <<EOH
${CSI_CONFIG}
EOH
      }

      resources {
        cpu    = 100
        memory = 200
      }
    }
  }
}