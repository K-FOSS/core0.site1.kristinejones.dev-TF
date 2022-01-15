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

      Deploy = tomap({
        DataChoices = {
          Path = "etc/org.opennms.features.datachoices.cfg"

          File = file("${path.module}/Configs/OpenNMS/Deploy/DataChoices.cfg")
        },
        Users = {
          Path = "etc/users.xml"

          File = file("${path.module}/Configs/OpenNMS/Deploy/Users.xml")
        },
        PollerConfig = {
          Path = "etc/poller-configuration.xml"

          File = file("${path.module}/Configs/OpenNMS/Deploy/PollerConfiguration.xml")
        },
        Cortex = {
          Path = "etc/org.opennms.plugins.tss.cortex.cfg"

          File = file("${path.module}/Configs/OpenNMS/Deploy/Cortex.cfg")
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