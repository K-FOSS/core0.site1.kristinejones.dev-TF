job "container-metrics" {
  datacenters = ["core0site1"]

  group "cadvisor-exporter-server" {
    count = 4

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "metrics" {
        to = 8080
      }
    }

    #
    # Root FS
    #

    volume "rootfs" {
      type = "host"
      read_only = true
      source = "system-rootfs"
    }

    #
    # Var RUN
    #

    volume "run" {
      type = "host"
      read_only = true
      source = "system-varrun"
    }

    #
    # Sys
    #

    volume "sys" {
      type = "host"
      read_only = true
      source = "system-sys"
    }

    #
    # Docker Daemon Socket
    #

    volume "docker-socket" {
      type = "host"
      read_only = true
      source = "docker-socket"
    }

    #
    # Disk
    #

    volume "disk" {
      type = "host"
      read_only = true
      source = "system-disk"
    }


    service {
      name = "cadvisor"
      port = "metrics"

      task = "cadvisor-exporter"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics"]
    }

    task "cadvisor-exporter" {
      driver = "docker"

      config {
        image = "gcr.io/cadvisor/cadvisor:${cAdvisor.Version}"

        privileged = true
        
        devices = [
          {
            host_path = "/dev/kmsg"
            container_path = "/dev/kmsg"
            cgroup_permissions = "r"
          }
        ] 
      }

      volume_mount {
        volume = "rootfs"
        destination = "/rootfs"
      }

      volume_mount {
        volume = "run"
        destination = "/var/run"
      }

      volume_mount {
        volume = "sys"
        destination = "/sys"
      }

      volume_mount {
        volume = "docker-socket"
        destination = "/var/lib/docker"
      }

      volume_mount {
        volume = "disk"
        destination = "/dev/disk"
      }

      template {
        data = <<EOH
DEVICE_USER="${iDRAC.Username}"
IDRAC_USER="${iDRAC.Username}"
DEVICE_PASSWORD="${iDRAC.Password}"
IDRAC_PASSWORD="${iDRAC.Password}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }
}