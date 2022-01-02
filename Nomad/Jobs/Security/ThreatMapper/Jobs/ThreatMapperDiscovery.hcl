job "security-threatmapper-discovery" {
  datacenters = ["core0site1"]

  group "threatmapper-discovery-server" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 8004
      }

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    task "wait-for-threatmapper-topology" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z https.topology.threatmapper.service.kjdev 6379; do sleep 1; done"]
      }

      resources {
        cpu = 16
        memory = 16
      }
    }

    service {
      name = "threatmapper"
      port = "http"

      task = "threatmapper-discovery-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.discovery"]
    }

    task "threatmapper-topology-server" {
      driver = "docker"

      config {
        image = "${ThreatMapper.Image.Repo}/deepfence_discovery_ce:${ThreatMapper.Image.Tag}"

        args = ["discovery", "http.topology.threatmapper.service.kjdev"]

        memory_hard_limit = 1024

        privileged = true

        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
          "/run/containerd/containerd.sock:/run/containerd/containerd.sock",
          "/sys/kernel/debug:/sys/kernel/debug"
        ]

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
          target = "/var/run"
          source = "/var/run"
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

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=threatmapper,service=topology"
          }
        }
      }

      env {
        #
        # TODO
        # 
        DF_CLUSTER_NAME = ""

        AGENT_HOSTNAME = ""

        SCOPE_HOSTNAME = ""


        
      }

      resources {
        cpu = 128

        memory = 1050
        memory_max = 1024
      }
    }
  }
}