job "storage-controller" {
  datacenters = ["core0site1"]
  type = "service"

  priority = 100

  group "controller" {
    count = 4

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    update {
      max_parallel = 1
      health_check = "task_states"

      healthy_deadline = "1m"
      progress_deadline = "30m"
    }

    network {
      mode = "cni/nomadcore1"

      port "grpc" {
        to = 9000
      }
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
        image = "democraticcsi/democratic-csi:v1.4.2"

        args = [
          "--csi-version=1.5.0",
          "--csi-name=org.democratic-csi.nfs",
          "--driver-config-file=$${NOMAD_TASK_DIR}/driver-config-file.yaml",
          "--log-level=debug",
          "--csi-mode=controller",
          "--server-socket=/csi-data/csi.sock",
          "--server-address=0.0.0.0",
          "--server-port=9000",
        ]

        privileged = true
      }

      csi_plugin {
        id = "truenas"
        type = "controller"
        mount_dir = "/csi-data"
      }

      template {
        destination = "$${NOMAD_TASK_DIR}/driver-config-file.yaml"

        data = <<EOH
${CSI_CONFIG}
EOH
      }

      resources {
        cpu    = 50
        memory = 100
      }
    }
  }
}