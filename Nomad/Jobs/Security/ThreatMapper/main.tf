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
  ThreatMapper = {
    Image = {
      Repo = "registry.kristianjones.dev/cache/deepfenceio"

      Tag = "latest"
    }

    Database = var.Database
  }
}


#
# ThreatMapper Job Files
#

#
# ThreatMapper API
#
resource "nomad_job" "ThreatMapperAPIJobFile" {
  jobspec = templatefile("${path.module}/Jobs/ThreatMapperAPI.hcl", {
    ThreatMapper = local.ThreatMapper
  })
}

#
# ThreatMapper Backend
#

#
# ThreatMapper Celery
#

#
# ThreatMapper Dianosis
#

#
# ThreatMapper Discovery
# 

#
# ThreatMapper Fetcher
#

resource "nomad_job" "ThreatMapperFetcherJobFile" {
  jobspec = templatefile("${path.module}/Jobs/ThreatMapperFetcher.hcl", {
    ThreatMapper = local.ThreatMapper
  })
}