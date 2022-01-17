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
        to = 8181
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

        mount {
          type = "bind"
          target = "/opt/sentinel-etc-overlay/persistence.boot"
          source = "local/Features/persistence.boot"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/sentinel-etc-overlay/flows.boot"
          source = "local/Features/flows.boot"
          readonly = false
        }

%{ for DeployFile in OpenNMS.Configs.Sentinel ~}
        mount {
          type = "bind"
          target = "/opt/sentinel-etc-overlay/${DeployFile.Path}"
          source = "local/deploy/${DeployFile.Path}"
          readonly = false
        }
%{ endfor ~}
      }

      env {
        #
        # OpenNMS Configuration
        #
        OPENNMS_HTTP_URL = "http://http.horizion.opennms.service.kjdev:8980/opennms"

        #
        # System
        #
        MAX_FD = "65536"

        MEM_TOTAL_MB = "2048"
        #JAVA_OPTS = ""

        #
        # Sentinel
        #
        SENTINEL_LOCATION = "dc1"
        SENTINEL_ID = "$${NOMAD_ALLOC_NAME}"
      }

      template {
        data = <<EOF
sentinel-persistence
sentinel-jsonstore-postgres
EOF

        destination = "local/Features/persistence.boot"

        perms = "777"
      }

      template {
        data = <<EOF
sentinel-flows
EOF

        destination = "local/Features/flows.boot"

        perms = "777"
      }

%{ for DeployFile in OpenNMS.Configs.Sentinel ~}
      template {
        data = <<EOF
${DeployFile.File}
EOF

        destination = "local/deploy/${DeployFile.Path}"

        perms = "777"
      }
%{ endfor ~}

      resources {
        cpu = 512

        memory = 512
        memory_max = 2048
      }
    }
  }
}