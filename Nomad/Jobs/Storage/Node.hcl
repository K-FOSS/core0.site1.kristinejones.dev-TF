job "storage-node" {
  datacenters = ["core0site1"]
  type        = "system"

  group "node" {
    network {
      mode = "cni/storage0"
    }

    update {
      max_parallel      = 1
      health_check      = "task_states"
      min_healthy_time  = "10s"
      healthy_deadline  = "3m"
      progress_deadline = "5m"
    }

    task "node" {
      driver = "docker"

      config {
        image = "democraticcsi/democratic-csi:latest"

        args = [
          "--csi-version=1.5.0",
          "--csi-name=org.democratic-csi.nfs",
          "--driver-config-file=$${NOMAD_TASK_DIR}/driver-config-file.yaml",
          "--log-level=debug",
          "--csi-mode=node",
          "--server-socket=/csi-data/csi.sock"
        ]

        privileged = true
      }

      csi_plugin {
        id        = "truenas"
        type      = "node"
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