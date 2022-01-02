job "security-threatmapper-topology" {
  datacenters = ["core0site1"]

  group "threatmapper-topology-server" {
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

    service {
      name = "threatmapper"
      port = "http"

      task = "threatmapper-topology-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.topology"]
    }

    task "threatmapper-topology-server" {
      driver = "docker"

      config {
        image = "${ThreatMapper.Image.Repo}/deepfence_discovery_ce:${ThreatMapper.Image.Tag}"

        args = ["topology"]

        memory_hard_limit = 512

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=threatmapper,service=topology"
          }
        }
      }

      resources {
        cpu = 128

        memory = 256
        memory_max = 512
      }
    }
  }
}