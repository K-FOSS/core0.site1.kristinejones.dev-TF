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

#
# Grafana Tempo
#

locals {
  Tempo = {
    YAMLConfig = templatefile("${path.module}/Configs/Tempo/Tempo.yaml", var.Tempo)
    
    Version = "main-a2d8715"
  }
}

#
# Grafana Tempo Distributor
#

resource "nomad_job" "TempoDistributorJobFile" {
  jobspec = templatefile("${path.module}/Jobs/TempoDistributor.hcl", {
    Tempo = local.Tempo
  })
}

#
# Grafana Tempo Ingester
#

resource "nomad_job" "TempoIngesterJobFile" {
  jobspec = templatefile("${path.module}/Jobs/TempoIngester.hcl", {
    Tempo = local.Tempo
  })
}

#
# Grafana Tempo Query Frontend
#

resource "nomad_job" "TempoQueryFrontendJobFile" {
  jobspec = templatefile("${path.module}/Jobs/TempoQueryFrontend.hcl", {
    Tempo = local.Tempo
  })
}

#
# Grafana Tempo Querier
#

resource "nomad_job" "TempoQuerierJobFile" {
  jobspec = templatefile("${path.module}/Jobs/TempoQuerier.hcl", {
    Tempo = local.Tempo
  })
}

#
# Grafana Tempo Compactor
#

resource "nomad_job" "TempoCompactorJobFile" {
  jobspec = templatefile("${path.module}/Jobs/TempoCompactor.hcl", {
    Tempo = local.Tempo
  })
}