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
  Vikunja = {
    Config = templatefile("${path.module}/Configs/Vikunja/Config.yaml", {
      Database = var.Database
    })
  }
}

#
# API
#

resource "nomad_job" "VikunjaAPIServerJobFile" {
  jobspec = templatefile("${path.module}/Jobs/VikunjaAPI.hcl", {
    Vikunja = local.Vikunja
  })
}

#
# Frontend
#

resource "nomad_job" "VikunjaFrontendServerJobFile" {
  jobspec = templatefile("${path.module}/Jobs/VikunjaFrontend.hcl", {
    Vikunja = local.Vikunja
  })
}