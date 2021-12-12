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
  Teleport = {
    Repo = "registry.kristianjones.dev/teleport/teleport"

    YAMLConfig = templatefile("${path.module}/Configs/Teleport/TeleportAuth.yaml", {
    })

    SSOConfig = templatefile("${path.module}/Configs/Teleport/Authentik.yaml", {
      OpenID = var.OpenID
    })

    Version = "8.0.0"
  }
}

#
# Auth Service
#

resource "nomad_job" "TeleportAuthJobFile" {
  jobspec = templatefile("${path.module}/Jobs/TeleportAuth.hcl", {
    Teleport = local.Teleport
  })
}

#
# Proxy Service
#

# resource "nomad_job" "TeleportProxyJobFile" {
#   jobspec = templatefile("${path.module}/Jobs/TeleportProxy.hcl", {
#     Teleport = local.Teleport
#   })
# }
 