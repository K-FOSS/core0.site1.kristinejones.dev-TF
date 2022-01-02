job "security-threatmapper-diagnosis" {
  datacenters = ["core0site1"]

  group "threatmapper-diagnosis-server" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" { 
        to = 8009
      }

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    task "wait-for-threatmapper-redis" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z redis.threatmapper.service.kjdev 6379; do sleep 1; done"]
      }

      resources {
        cpu = 16
        memory = 16
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
      port = "https"

      task = "threatmapper-diagnosis-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.diagnosis"]

      meta {
        meta = "for your service"
      }
    }

    task "threatmapper-diagnosis-server" {
      driver = "docker"

      config {
        image = "${ThreatMapper.Image.Repo}/deepfence_diagnosis_ce:${ThreatMapper.Image.Tag}"

        memory_hard_limit = 200

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=threatmapper,service=diagnosis"
          }
        }
      }

      env {
        #
        # TODO
        #
        ANALYZER_REPLICATION_FACTOR = "1"

        ANALYZER_SERVICE_NAME_PREFIX = "deepfence-analyzer-"

        mapper_image_name = ""
        image_tag = ""

        router_service = "https.router.threatmapper.service.kjdev:443"
        VULNERABILITY_SCAN_CONCURRENCY = "10"
      }

      resources {
        cpu = 128

        memory = 64
        memory_max = 200
      }
    }
  }
}