job "network-monitoring-opennms-nephron" {
  datacenters = ["core0site1"]

  group "opennms-sentinel-server" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8980
      }
    }

    service {
      name = "opennms"
      port = "http"

      task = "opennms-sentinel-server"
      address_mode = "alloc"

      tags = ["http.sentinel"]
    }
    
    task "opennms-sentinel-server" {
      driver = "docker"

      config {
        image = "${OpenNMS.Image.Repo}/sentinel:${OpenNMS.Image.Tag}"

        args = ["-s"]

        memory_hard_limit = 2048
      }

      env {
        OPENNMS_HTTP_URL = "http://http.horizion.opennms.service.kjdev:8980/opennms"

        #
        # System
        #
        MAX_FD = "65536"

        MEM_TOTAL_MB = "2048"
        #JAVA_OPTS = ""

        #
        #
        #
        SENTINEL_LOCATION = "$${NOMAD_ALLOC_NAME}"
      }

      resources {
        cpu = 512

        memory = 512
        memory_max = 2048
      }
    }
  }
}