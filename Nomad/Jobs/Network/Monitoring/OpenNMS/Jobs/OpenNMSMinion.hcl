job "network-monitoring-opennms-minion" {
  datacenters = ["core0site1"]

  group "opennms-minion-server" {
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

      port "flows" {
        to = 9999
      }
    }

    service {
      name = "opennms"
      port = "http"

      task = "opennms-minion-server"
      address_mode = "alloc"

      tags = ["http.minion"]
    }

    service {
      name = "opennms"
      port = "flows"

      task = "opennms-minion-server"
      address_mode = "alloc"

      tags = ["flows.minion"]
    }
    
    task "opennms-minion-server" {
      driver = "docker"

      config {
        image = "${OpenNMS.Image.Repo}/minion:${OpenNMS.Image.Tag}"

        args = ["-s"]

        memory_hard_limit = 2048
      }

      env {
        #
        # OpenNMS
        #
        OPENNMS_HTTP_URL = ""

      }
    }
  }
}