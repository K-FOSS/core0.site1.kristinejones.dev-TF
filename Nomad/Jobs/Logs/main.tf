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

data "github_repository" "VectorRepo" {
  full_name = "vectordotdev/vector"
}

data "github_release" "VectorRelease" {
  repository  = data.github_repository.VectorRepo.name
  owner       = split("/", data.github_repository.VectorRepo.full_name)[0]
  retrieve_by = "latest"
}

resource "nomad_job" "SyslogJobFile" {
  jobspec = templatefile("${path.module}/Jobs/Syslog.hcl", {
    Vector = {
      Config = templatefile("${path.module}/Configs/Vector/Vector.yaml", {

      })

      Version = split("v", data.github_release.VectorRelease.release_tag)[1]
    }
  })
}

#
# Grafana Loki Time Series Structured Data
#

locals {
  Loki = {
    YAMLConfig = templatefile("${path.module}/Configs/Loki/Loki.yaml", var.Loki)

    Version = "master"
  }
}

#
# Distributor
#

resource "nomad_job" "LokiDistributorJobFile" {
  jobspec = templatefile("${path.module}/Jobs/Loki/LokiDistributor.hcl", {
    Loki = local.Loki
  })
}

#
# Loki Querier
#

resource "nomad_job" "LokiQuerierJobFile" {
  jobspec = templatefile("${path.module}/Jobs/Loki/LokiQuerier.hcl", {
    Loki = local.Loki
  })
}

#
# Loki Query Scheduler
#

resource "nomad_job" "LokiQuerySchedulerJobFile" {
  jobspec = templatefile("${path.module}/Jobs/Loki/LokiQueryScheduler.hcl", {
    Loki = local.Loki
  })
}

#
# Loki Query Frontend
#

resource "nomad_job" "LokiQueryFrontendJobFile" {
  jobspec = templatefile("${path.module}/Jobs/Loki/LokiQueryFrontend.hcl", {
    Loki = local.Loki
  })
}

#
# Loki Ruler
#

resource "nomad_job" "LokiRulerJobFile" {
  jobspec = templatefile("${path.module}/Jobs/Loki/LokiRuler.hcl", {
    Loki = local.Loki
  })
}

#
# Loki Ingester
#

resource "nomad_job" "LokiIngesterJobFile" {
  jobspec = templatefile("${path.module}/Jobs/Loki/LokiIngester.hcl", {
    Loki = local.Loki
  })
}

#
# Loki Index Gateway
#

resource "nomad_job" "LokiIndexGatewayJobFile" {
  jobspec = templatefile("${path.module}/Jobs/Loki/LokiIndexGateway.hcl", {
    Loki = local.Loki
  })
}