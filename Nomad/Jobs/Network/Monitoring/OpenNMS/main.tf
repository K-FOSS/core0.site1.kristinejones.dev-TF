terraform {
  required_providers {
    #
    # Hashicorp Vault
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    #
    nomad = {
      source = "hashicorp/nomad"
      version = "1.4.15"
    }

    #
    # GitHub Provider
    #
    # Used to fetch the latest PSQL file
    #
    # Docs: https://registry.terraform.io/providers/integrations/github/latest
    #
    github = {
      source = "integrations/github"
      version = "4.17.0"
    }

    #
    # Hashicorp Terraform HTTP Provider
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/http/latest/docs
    #
    http = {
      source = "hashicorp/http"
      version = "2.1.0"
    }

    #
    # Randomness
    #
    # TODO: Find a way to best improve true randomness?
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/random/latest/docs
    #
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

locals {
  OpenNMS = {
    Image = {
      Repo = "registry.kristianjones.dev/cache/opennms"

      Tag = "bleeding"
    }

    Configs = {
      Auth = {
        HeaderAuth = file("${path.module}/Configs/OpenNMS/Auth/HeaderAuth.xml")

        LDAP = templatefile("${path.module}/Configs/OpenNMS/Auth/LDAP.xml", {
          LDAP = var.LDAP
        })

        SpringContext = file("${path.module}/Configs/OpenNMS/Auth/applicationContext-spring-security.xml")
      }

      Minion = tomap({
        CustomSystemProperties = {
          Path = "custom.system.properties"

          File = file("${path.module}/Configs/OpenNMS/Minion/CustomSystemProperties.cfg")          
        },
        DNS = {
          Path = "org.opennms.features.dnsresolver.netty.cfg"

          File = file("${path.module}/Configs/OpenNMS/Deploy/DNS.cfg")
        },
        SinglePort = {
          Path = "/org.opennms.features.telemetry.listeners-udp-9999.cfg"

          File = file("${path.module}/Configs/OpenNMS/Minion/SinglePort.cfg")
        },
        KafkaIPC = {
          Path = "org.opennms.core.ipc.sink.kafka.cfg"

          File = file("${path.module}/Configs/OpenNMS/Minion/KafkaSink.cfg")
        },
        KafkaSink = {
          Path = "org.opennms.core.ipc.rpc.kafka.cfg"

          File = file("${path.module}/Configs/OpenNMS/Minion/KafkaRPCIPC.cfg")
        },
        OffheapSink = {
          Path = "org.opennms.core.ipc.sink.offheap.cfg"

          File = file("${path.module}/Configs/OpenNMS/Minion/OffheapSink.cfg")
        }
      })

      Sentinel = tomap({
        DNS = {
          Path = "org.opennms.features.dnsresolver.netty.cfg"

          File = file("${path.module}/Configs/OpenNMS/Deploy/DNS.cfg")
        },
        CustomSystemProperties = {
          Path = "custom.system.properties"

          File = file("${path.module}/Configs/OpenNMS/Sentinel/CustomSystemProperties.cfg")          
        },
        ElasticSearch = {
          Path = "org.opennms.features.flows.persistence.elastic.cfg"

          File = file("${path.module}/Configs/OpenNMS/Sentinel/ElasticSearch.cfg")          
        },
        Netflow9 = {
          Path = "org.opennms.features.telemetry.adapters-netflow9.cfg"

          File = file("${path.module}/Configs/OpenNMS/Sentinel/Netflow9.cfg")          
        },
        Netflow5 = {
          Path = "org.opennms.features.telemetry.adapters-netflow5.cfg"

          File = file("${path.module}/Configs/OpenNMS/Sentinel/Netflow5.cfg")          
        },
        SFlow = {
          Path = "org.opennms.features.telemetry.adapters-sflow.cfg"

          File = file("${path.module}/Configs/OpenNMS/Sentinel/SFlow.cfg")          
        },
        IPFix = {
          Path = "org.opennms.features.telemetry.adapters-ipfix.cfg"

          File = file("${path.module}/Configs/OpenNMS/Sentinel/IPFix.cfg")          
        },
      })

      Horizion = tomap({
        DNS = {
          Path = "etc/org.opennms.features.dnsresolver.netty.cfg"

          File = file("${path.module}/Configs/OpenNMS/Deploy/DNS.cfg")
        },
        DataChoices = {
          Path = "etc/org.opennms.features.datachoices.cfg"

          File = file("${path.module}/Configs/OpenNMS/Deploy/DataChoices.cfg")
        },
        Users = {
          Path = "etc/users.xml"

          File = file("${path.module}/Configs/OpenNMS/Deploy/Users.xml")
        },
        Discovery = {
          Path = "etc/discovery-configuration.xml"

          File = file("${path.module}/Configs/OpenNMS/Deploy/Discovery.xml")
        },
        PollerConfig = {
          Path = "etc/poller-configuration.xml"

          File = file("${path.module}/Configs/OpenNMS/Deploy/PollerConfiguration.xml")
        },
        NetFlowListener = {
          Path = "etc/org.opennms.features.telemetry.listeners-udp-4729.cfg"

          File = file("${path.module}/Configs/OpenNMS/Deploy/NetFlow9.cfg")
        },
        NetFlow = {
          Path = "etc/org.opennms.netmgt.telemetry.protocols.netflow.parser.Netflow9UdpParser.cfg"

          File = file("${path.module}/Configs/OpenNMS/Deploy/NetFlowParser.cfg")
        },
        Cortex = {
          Path = "etc/org.opennms.plugins.tss.cortex.cfg"

          File = file("${path.module}/Configs/OpenNMS/Deploy/Cortex.cfg")
        },
        Kafka = {
          Path = "etc/opennms.properties.d/kafka.properties"

          File = file("${path.module}/Configs/OpenNMS/Deploy/Kafka.properties")
        },
        ElasticSearch = {
          Path = "etc/org.opennms.features.flows.persistence.elastic.cfg"

          File = file("${path.module}/Configs/OpenNMS/Deploy/ElasticSearchConfig.cfg")
        },
        Telemetryd = {
          Path = "etc/telemetryd-configuration.xml"

          File = file("${path.module}/Configs/OpenNMS/Deploy/Telemetryd.xml")
        },
        ServiceConfig = {
          Path = "etc/service-configuration.xml"

          File = file("${path.module}/Configs/OpenNMS/Deploy/ServiceConfiguration.xml")
        },
        SNMP = {
          Path = "etc/snmp-config.xml"

          File = file("${path.module}/Configs/OpenNMS/Deploy/SNMPConfig.xml")
        },
        SNMPInterfacePoller = {
          Path = "etc/snmp-interface-poller-configuration.xml"

          File = file("${path.module}/Configs/OpenNMS/Deploy/SNMPInterfacePoller.xml")
        },
        Jaeger = {
          Path = "etc/opennms.properties.d/jaeger.properties"

          File = file("${path.module}/Configs/OpenNMS/Deploy/Jaeger.properties")
        },
        TimeSeries = {
          Path = "etc/opennms.properties.d/timeseries.properties"

          File = file("${path.module}/Configs/OpenNMS/Deploy/TimeSeries.properties")
        },
        WebUI = {
          Path = "etc/opennms.properties.d/webui.properties"

          File = file("${path.module}/Configs/OpenNMS/Deploy/WebUI.properties")
        },
        DataSources = {
          Path = "etc/opennms-datasources.xml",

          File = templatefile("${path.module}/Configs/OpenNMS/Deploy/DataSources.xml", {
            Database = var.Database
          })
        }
      })

      HorizionConfig = templatefile("${path.module}/Configs/OpenNMS/ConfD/Horizion.yaml", {
        Database = var.Database
      })
    }
  }
}

#
# OpenNMS
#

resource "nomad_job" "OpenNMSHorizionJobFile" {
  jobspec = templatefile("${path.module}/Jobs/OpenNMSCoreServer.hcl", {
    OpenNMS = local.OpenNMS
  })
}

#
# Sentinel
# 

resource "nomad_job" "OpenNMSSentinelJobFile" {
  jobspec = templatefile("${path.module}/Jobs/OpenNMSSentinel.hcl", {
    OpenNMS = local.OpenNMS
  })
}

#
# Minion
#

resource "nomad_job" "OpenNMSMinionJobFile" {
  jobspec = templatefile("${path.module}/Jobs/OpenNMSMinion.hcl", {
    OpenNMS = local.OpenNMS
  })
}