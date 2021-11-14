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

        mount {
          type = "bind"
          target = "/rootfs"
          source = "/"
          readonly = true
          bind_options {
            propagation = "rshared"
          }
        }

        mount {
          type = "bind"
          target = "/var/run"
          source = "/var/run"
          readonly = true
          bind_options {
            propagation = "rshared"
          }
        }

        mount {
          type = "bind"
          target = "/sys"
          source = "/sys"
          readonly = true
          bind_options {
            propagation = "rshared"
          }
        }

        mount {
          type = "bind"
          target = "/var/lib/docker"
          source = "/var/lib/docker/"
          readonly = true
          bind_options {
            propagation = "rshared"
          }
        }

        mount {
          type = "bind"
          target = "/dev/disk"
          source = "/dev/disk"
          readonly = true
          bind_options {
            propagation = "rshared"
          }
        }
      }
    }
  }
}