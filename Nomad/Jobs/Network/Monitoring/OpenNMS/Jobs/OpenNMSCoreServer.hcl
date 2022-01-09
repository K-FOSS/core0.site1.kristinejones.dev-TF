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
    }

    service {
      name = "opennms"
      port = "http"

      task = "opennms-core-server"
      address_mode = "alloc"

      tags = ["http.horizion"]
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
          target = "/opt/opennms-overlay/etc/org.opennms.plugins.tss.cortex.cfg"
          source = "local/etc/org.opennms.plugins.tss.cortex.cfg"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/opennms-overlay/etc/opennms.properties"
          source = "local/OpenNMS.properties"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/opennms-overlay/etc/users.xml"
          source = "local/users.xml"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/opennms-overlay/etc/service-configuration.xml"
          source = "local/service-configuration.xml"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/opennms-overlay/etc/poller-configuration.xml"
          source = "local/poller-configuration.xml"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/opennms-overlay/etc/snmp-interface-poller-configuration.xml"
          source = "local/snmp-interface-poller-configuration.xml"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/opennms-overlay/etc/snmp-config.xml"
          source = "local/snmp-config.xml"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/opennms-overlay/etc/opennms.properties.d/jaeger.properties"
          source = "local/opennms.properties.d/jaeger.properties"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/opennms-overlay/etc/opennms.properties.d/cortex.properties"
          source = "local/opennms.properties.d/cortex.properties"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/opennms-overlay/etc/featuresBoot.d/cortex.boot"
          source = "local/featuresBoot.d/cortex.boot"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/etc/confd/confd.toml"
          source = "local/HorizionConfig.toml"
          readonly = false
        }

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

      template {
        data = <<EOF
${OpenNMS.Configs.CortexConfig}
EOF

        destination = "local/etc/org.opennms.plugins.tss.cortex.cfg"

        perms = "777"
      }

      #
      # Configs
      #

      template {
        data = <<EOF
${OpenNMS.Configs.OpenNMSProperties}
EOF

        destination = "local/OpenNMS.properties"

        perms = "777"
      }

      template {
        data = <<EOF
${OpenNMS.Configs.Users}
EOF

        destination = "local/users.xml"

        perms = "777"
      }

      template {
        data = <<EOF
${OpenNMS.Configs.ServiceConfiguration}
EOF

        destination = "local/service-configuration.xml"

        perms = "777"
      }

      template {
        data = <<EOF
${OpenNMS.Configs.PollerConfig}
EOF

        destination = "local/poller-configuration.xml"

        perms = "777"
      }

      template {
        data = <<EOF
${OpenNMS.Configs.SNMPPollerConfig}
EOF

        destination = "local/snmp-interface-poller-configuration.xml"

        perms = "777"
      }

      template {
        data = <<EOF
${OpenNMS.Configs.SNMPConfig}
EOF

        destination = "local/snmp-config.xml"

        perms = "777"
      }


      #
      # Configs/opennms.properties.d
      # 

      template {
        data = <<EOF
org.opennms.timeseries.strategy=integration
org.opennms.timeseries.tin.metatags.tag.node=$${node:label}
org.opennms.timeseries.tin.metatags.tag.location=$${node:location}
org.opennms.timeseries.tin.metatags.tag.geohash=$${node:geohash}
org.opennms.timeseries.tin.metatags.tag.ifDescr=$${interface:if-description}
org.opennms.timeseries.tin.metatags.tag.label=$${resource:label}
EOF

        destination = "local/opennms.properties.d/cortex.properties"

        perms = "777"
      }

      template {
        data = "opennms-plugins-cortex-tss wait-for-kar=opennms-cortex-tss-plugin"

        destination = "local/featuresBoot.d/cortex.boot"

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
${OpenNMS.Configs.JaegerConfig}
EOF

        destination = "local/opennms.properties.d/jaeger.properties"

        perms = "777"
      }


      resources {
        cpu = 512

        memory = 4096
        memory_max = 8096
      }
    }
  }
}