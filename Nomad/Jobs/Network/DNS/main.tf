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

# data "github_repository" "Repo" {
#   full_name = "coredns/coredns"
# }

# data "github_release" "Release" {
#   repository  = data.github_repository.Repo.name
#   owner       = split("/", data.github_repository.Repo.full_name)[0]
#   retrieve_by = "latest"
# }


resource "nomad_job" "RDNSJobFile" {
  jobspec = templatefile("${path.module}/Jobs/RNS.hcl", {
    #Version = split("v", data.github_release.Release.release_tag)[1]

    CoreFile = templatefile("${path.module}/Configs/RNS/Corefile", {
      Netbox = var.Netbox

      Consul = var.Consul

      Database = var.PowerDNS.Database
    })

    PluginsConfig = templatefile("${path.module}/Configs/plugin.cfg", {})
  })
}

#
# Service DNS
#

resource "nomad_job" "ServiceDNSJobFile" {
  jobspec = templatefile("${path.module}/Jobs/ServiceDNS.hcl", {
    #Version = split("v", data.github_release.Release.release_tag)[1]

    CoreFile = templatefile("${path.module}/Configs/ServiceDNS/Corefile", {
      Netbox = var.Netbox

      Consul = var.Consul
    })

    PluginsConfig = templatefile("${path.module}/Configs/plugin.cfg", {})
  })
}

#
# Network DNS
#

resource "nomad_job" "NetworkDNSJobFile" {
  jobspec = templatefile("${path.module}/Jobs/NetworkDNS.hcl", {
    #Version = split("v", data.github_release.Release.release_tag)[1]

    CoreFile = templatefile("${path.module}/Configs/NetworkDNS/Corefile", {
      Netbox = var.Netbox

      Consul = var.Consul
    })

    PluginsConfig = templatefile("${path.module}/Configs/plugin.cfg", {})
  })
}

#
# Public NS
#

resource "nomad_job" "PublicNSJobFile" {
  jobspec = templatefile("${path.module}/Jobs/PublicNS.hcl", {
    #Version = split("v", data.github_release.Release.release_tag)[1]

    CoreFile = templatefile("${path.module}/Configs/PNS/Corefile", {
      Database = var.PowerDNS.Database
    })

    PluginsConfig = templatefile("${path.module}/Configs/plugin.cfg", {})
  })
}