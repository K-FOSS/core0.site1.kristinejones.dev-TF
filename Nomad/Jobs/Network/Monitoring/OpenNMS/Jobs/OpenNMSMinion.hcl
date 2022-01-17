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

        args = ["-c"]

        memory_hard_limit = 2048

        mount {
          type = "tmpfs"
          target = "/opt/minion-etc-overlay"
          readonly = false
          tmpfs_options = {
            size = 124000000
          }
        }

        mount {
          type = "bind"
          target = "/opt/minion-etc-overlay/featuresBoot.d/kafka.boot"
          source = "local/Plugins/kafka.boot"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/minion-etc-overlay/featuresBoot.d/jaeger.boot"
          source = "local/Plugins/jaeger.boot"
          readonly = false
        }

%{ for DeployFile in OpenNMS.Configs.Minion ~}
        mount {
          type = "bind"
          target = "/opt/minion-etc-overlay/${DeployFile.Path}"
          source = "local/deploy/${DeployFile.Path}"
          readonly = false
        }
%{ endfor ~}

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=opennms,service=minion"
          }
        }
      }

      env {
        #
        # OpenNMS
        #
        OPENNMS_HTTP_URL = "http://http.horizion.opennms.service.kjdev:8980/opennms"

        OPENNMS_HTTP_USER = "admin"
        OPENNMS_HTTP_PASS = "admin"

        #
        # Minion Settings
        #

        MINION_ID = ""
        MINION_LOCATION = "dc1"


        #
        # System
        #
        MEM_TOTAL_MB = "2048"
        JAVA_OPTS = "-Xms2048m -Xmx2048m -XX:+AlwaysPreTouch -XX:+UseG1GC -XX:+UseStringDeduplication"

        MAX_FD = "65536"

        #
        # Misc
        #
        TZ = "America/Winnipeg"
      }

      template {
        data = <<EOF
!minion-jms
!opennms-core-ipc-sink-camel
!opennms-core-ipc-rpc-jms
opennms-core-ipc-sink-kafka
opennms-core-ipc-rpc-kafka
EOF

        destination = "local/Plugins/kafka.boot"

        perms = "777"
      }

      template {
        data = <<EOF
!minion-jms
!opennms-core-ipc-sink-camel
!opennms-core-ipc-rpc-jms
opennms-core-ipc-sink-kafka
opennms-core-ipc-rpc-kafka
EOF

        destination = "local/Plugins/jaeger.boot"

        perms = "777"
      }

%{ for DeployFile in OpenNMS.Configs.Minion ~}
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