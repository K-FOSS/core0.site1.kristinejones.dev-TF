job "container-metrics" {
  datacenters = ["core0site1"]

  group "cadvisor-exporter-server" {
    count = 2

    constraint {
      operator = "distinct_hosts"
      value = "true"
    }

    network {
      mode = "cni/nomadcore1"

      port "metrics" {
        to = 9100
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

        args = ["-enable_load_reader", "-enable_metrics=advtcp,app,cpu,cpuLoad,cpu_topology,cpuset,disk,diskIO,memory,memory_numa,network,network,oom_event,percpu,perf_event,process,referenced_memory,resctrl,sched,sched,tcp,udp", "-store_container_labels=false"]

        privileged = true

        memory_hard_limit = 1024
        
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

      resources {
        cpu = 64
        memory = 64
        memory_max = 1024
      }
    }
  }
}