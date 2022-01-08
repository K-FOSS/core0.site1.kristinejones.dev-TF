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
      }

      HorizionConfig = templatefile("${path.module}/Configs/OpenNMS/ConfD/Horizion.yaml", {
        Database = var.Database
      })

      Users = file("${path.module}/Configs/OpenNMS/users.xml")

      ServiceConfiguration = file("${path.module}/Configs/OpenNMS/users.xml")

      OpenNMSProperties = file("${path.module}/Configs/OpenNMS/Properties/OpenNMS.properties")

      CortexConfig = templatefile("${path.module}/Configs/OpenNMS/org.opennms.plugins.tss.cortex.cfg", {

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