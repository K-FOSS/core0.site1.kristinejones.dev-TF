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
#   full_name = "pomerium/pomerium"
# }

# data "github_release" "Release" {
#   repository  = data.github_repository.Repo.name
#   owner       = split("/", data.github_repository.Repo.full_name)[0]
#   retrieve_by = "latest"
# }

#
# Authenticate
#

resource "nomad_job" "PomeriumAuthenticateJobFile" {
  jobspec = templatefile("${path.module}/Jobs/PomeriumAuthenticate.hcl", {
    TLS = var.TLS

    Service = var.Authenticate

    Config = templatefile("${path.module}/Configs/Pomerium/PomeriumAuthenticate.yaml", {
      Secrets = var.Secrets
      OpenID = var.OpenID
    })

    Version = "v0.15.3"
  })
}

#
# Authorize
#

resource "nomad_job" "PomeriumAuthorizeJobFile" {
  jobspec = templatefile("${path.module}/Jobs/PomeriumAuthorize.hcl", {
    TLS = var.TLS

    Service = var.Authorize

    Config = templatefile("${path.module}/Configs/Pomerium/PomeriumAuthorize.yaml", {
      Secrets = var.Secrets
      OpenID = var.OpenID
    })

    Version = "v0.15.3"
  })
}

#
# Data Broker
#

resource "nomad_job" "PomeriumDataBrokerJobFile" {
  jobspec = templatefile("${path.module}/Jobs/PomeriumDataBroker.hcl", {
    TLS = var.TLS

    Service = var.DataBroker

    Config = templatefile("${path.module}/Configs/Pomerium/PomeriumDataBroker.yaml", {
      Secrets = var.Secrets
      OpenID = var.OpenID
    })

    Version = "v0.15.3"
  })
}


#
# Proxy
#

resource "nomad_job" "PomeriumProxyJobFile" {
  jobspec = templatefile("${path.module}/Jobs/PomeriumProxy.hcl", {
    TLS = var.TLS

    Service = var.Proxy

    Config = templatefile("${path.module}/Configs/Pomerium/PomeriumProxy.yaml", {
      Secrets = var.Secrets
      OpenID = var.OpenID
    })

    Version = "v0.15.3"
  })
}