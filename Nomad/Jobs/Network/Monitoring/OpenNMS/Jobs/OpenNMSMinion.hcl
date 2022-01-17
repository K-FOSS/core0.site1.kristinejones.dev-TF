job "network-monitoring-opennms-minion" {
  datacenters = ["core0site1"]

  group "opennms-minion-server" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "flows" {
        to = 9999
      }

      port "shell" {
        to = 8201
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

    service {
      name = "opennms"
      port = "shell"

      task = "opennms-minion-server"
      address_mode = "alloc"

      tags = ["shell.minion"]
    }
    
    task "opennms-minion-server" {
      driver = "docker"

      config {
        image = "${OpenNMS.Image.Repo}/minion:${OpenNMS.Image.Tag}"

        args = ["-c", "-f"]

        privileged = true

        memory_hard_limit = 4096

        sysctl = {
          "net.ipv4.ping_group_range" = "0 429496729"
        }

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
          target = "/opt/minion/minion-config.yaml"
          source = "local/Config.yaml"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/minion-etc-overlay/featuresBoot.d/disable-activemq.boot"
          source = "local/Features/disable-activemq.boot"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/minion-etc-overlay/featuresBoot.d/kafka.boot"
          source = "local/Features/kafka.boot"
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

        MINION_ID = "$${NOMAD_ALLOC_NAME}"
        MINION_LOCATION = "dc1"


        #
        # System
        #
        MEM_TOTAL_MB = "2048"
        JAVA_OPTS = "-Xms2048m -Xmx2048m -XX:+AlwaysPreTouch -XX:+UseG1GC -XX:+UseStringDeduplication"

        #MAX_FD = "65536"

        #
        # Misc
        #
        TZ = "America/Winnipeg"
      }

      template {
        data = <<EOF
${OpenNMS.Configs.MinionConfigs.Config}
EOF

        destination = "local/Config.yaml"

        perms = "777"
      }

      template {
        data = <<EOF
!minion-jms
!opennms-core-ipc-jms
EOF

        destination = "local/Features/disable-activemq.boot"

        perms = "777"
      }

      template {
        data = <<EOF
opennms-core-ipc-kafka
EOF

        destination = "local/Features/kafka.boot"

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

        memory = 2048
        memory_max = 4096
      }
    }
  }
}