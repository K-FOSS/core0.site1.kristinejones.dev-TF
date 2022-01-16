job "network-monitoring-opennms-coreserver" {
  datacenters = ["core0site1"]

  group "opennms-core-server" {
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

      port "netflow" {
        to = 4729
      }

      port "graphite" {
        to = 2003
      }

      port "multi" {
        to = 9999
      }
    }

    service {
      name = "opennms"
      port = "http"

      task = "opennms-core-server"
      address_mode = "alloc"

      tags = ["http.horizion"]
    }

    service {
      name = "opennms"
      port = "netflow"

      task = "opennms-core-server"
      address_mode = "alloc"

      tags = ["netflow.horizion"]
    }

    service {
      name = "opennms"
      port = "graphite"

      task = "opennms-core-server"
      address_mode = "alloc"

      tags = ["graphite.horizion"]
    }

    service {
      name = "opennms"
      port = "multi"

      task = "opennms-core-server"
      address_mode = "alloc"

      tags = ["multi.horizion"]
    }

    task "opennms-core-server" {
      driver = "docker"

      config {
        image = "${OpenNMS.Image.Repo}/horizon:${OpenNMS.Image.Tag}"

        args = ["-s"]

        memory_hard_limit = 8096

        mount {
          type = "tmpfs"
          target = "/opt/opennms-overlay/etc"
          readonly = false
          tmpfs_options = {
            size = 124000000
          }
        }

        mount {
          type = "bind"
          target = "/opt/opennms-overlay/confd/horizon-config.yaml"
          source = "local/HorizionConfig.yaml"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/etc/confd/confd.toml"
          source = "local/HorizionConfig.toml"
          readonly = false
        }

%{ for DeployFile in OpenNMS.Configs.Deploy ~}
        mount {
          type = "bind"
          target = "/opt/opennms-overlay/${DeployFile.Path}"
          source = "local/deploy/${DeployFile.Path}"
          readonly = false
        }
%{ endfor ~}

        #
        # Plugins
        #
        mount {
          type = "bind"
          target = "/opt/opennms/deploy/opennms-cortex-tss-plugin.kar"
          source = "local/Artifacts/opennms-cortex-tss-plugin.kar"
          readonly = false
        }

        #
        # Features
        #

        mount {
          type = "bind"
          target = "/opt/opennms-overlay/etc/featuresBoot.d/jaeger.boot"
          source = "local/Plugins/jaeger.boot"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/opennms-overlay/etc/featuresBoot.d/cortex.boot"
          source = "local/Plugins/cortex.boot"
          readonly = false
        }

        #
        # Auth
        #
        mount {
          type = "bind"
          target = "/opt/opennms-jetty-webinf-overlay/spring-security.d/header-preauth.xml"
          source = "local/Auth/header-preauth.xml"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/opennms-jetty-webinf-overlay/spring-security.d/ldap.xml"
          source = "local/Auth/ldap.xml"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/opennms-jetty-webinf-overlay/applicationContext-spring-security.xml"
          source = "local/Auth/applicationContext-spring-security.xml"
          readonly = false
        }

        sysctl = {
          "net.ipv4.ping_group_range" = "0 429496729"
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=opennms,service=coreserver"
          }
        }
      }

      env {
        #
        # System
        #
        OPENNMS_INSTANCE_ID = "$${NOMAD_ALLOC_NAME}"
        #
        # Misc
        #
        TZ = "America/Winnipeg"


      }

      template {
        data = <<EOF
${OpenNMS.Configs.HorizionConfig}
EOF

        destination = "local/HorizionConfig.yaml"

        perms = "777"
      }

      template {
        data = <<EOF
confdir = "/etc/confd"
backend = "file"
file = [ "/opt/opennms-overlay/confd/horizon-config.yaml" ]
log-level = "info"
EOF

        destination = "local/HorizionConfig.toml"

        perms = "777"
      }

      #
      # Plugins
      #

      artifact {
        source = "https://github.com/OpenNMS/opennms-cortex-tss-plugin/releases/download/v1.0.0/opennms-cortex-tss-plugin.kar"
        destination = "local/Artifacts"
      }

      #
      # Auth
      # 

      template {
        data = <<EOF
${OpenNMS.Configs.Auth.HeaderAuth}
EOF

        destination = "local/Auth/header-preauth.xml"

        perms = "777"
      }

      template {
        data = <<EOF
${OpenNMS.Configs.Auth.SpringContext}
EOF

        destination = "local/Auth/applicationContext-spring-security.xml"

        perms = "777"
      }

      template {
        data = <<EOF
${OpenNMS.Configs.Auth.LDAP}
EOF

        destination = "local/Auth/ldap.xml"

        perms = "777"
      }

      template {
        data = "opennms-core-tracing-jaeger"

        destination = "local/Plugins/jaeger.boot"

        perms = "777"
      }

      template {
        data = <<EOF
opennms-plugins-cortex-tss wait-for-kar=opennms-cortex-tss-plugin
EOF

        destination = "local/Plugins/cortex.boot"

        perms = "777"
      }

%{ for DeployFile in OpenNMS.Configs.Deploy ~}
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

        memory = 4096
        memory_max = 8096
      }
    }
  }
}