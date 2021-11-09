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

resource "nomad_job" "CortexJob" {
  jobspec = templatefile("${path.module}/Jobs/Cortex.hcl", {
    Cortex = {
      Targets = var.Cortex.Targets

      Database = var.Cortex.Database

      YAMLConfig = templatefile("${path.module}/Configs/Cortex/Cortex.yaml", var.Cortex)

      Version = "master-85c3781"
    }
  })
}

resource "nomad_job" "PrometheusJob" {
  jobspec = templatefile("${path.module}/Jobs/Prometheus.hcl", {
    Prometheus = {
      YAMLConfig = templatefile("${path.module}/Configs/Prometheus/Prometheus.yaml", {
        CoreVault = var.Prometheus.CoreVault
        Vault = var.Prometheus.Vault
      })

      Grafana = var.Prometheus.Grafana

      iDRAC = {
        Devices = var.iDRAC.Devices
      }

      Version = "v2.30.0"
    }
  })
}

#
# StarLink Exporter
#

resource "nomad_job" "StarLinkJob" {
  jobspec = templatefile("${path.module}/Jobs/StarLink.hcl", {
    StarLink = {
      IPAddress = "192.168.100.1"

      Port = "9200"

      Version = "latest"
    }
  })
}

#
# MikroTik Exporter
# 
resource "nomad_job" "MikroTikJob" {
  jobspec = templatefile("${path.module}/Jobs/MikroTik.hcl", {
    MikroTik = {
      Config = templatefile("${path.module}/Configs/MikroTik/Config.yaml", {
        Devices = var.MikroTik.Devices
      })

      Version = "1.0.12-DEVEL"
    }
  })
}

#
# PostgreSQL Exporter
#
# resource "nomad_job" "PostgreSQLJob" {
#   jobspec = templatefile("${path.module}/Jobs/PostgreSQL.hcl", {
#     PostgreSQL = {
#       Config = templatefile("${path.module}/Configs/MikroTik/Config.yaml", {
#         Devices = var.MikroTik.Devices
#       })

#       Version = "1.0.12-DEVEL"
#     }
#   })
# }

#
# iDRAC Exporter
#

resource "nomad_job" "iDRACJobFile" {
  jobspec = templatefile("${path.module}/Jobs/iDRAC.hcl", {
    iDRAC = {
      Username = var.iDRAC.Username
      Password = var.iDRAC.Password
    }
  })
}