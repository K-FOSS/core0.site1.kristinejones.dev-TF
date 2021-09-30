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
      version = "4.15.1"
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

data "github_repository" "Repo" {
  full_name = "pomerium/pomerium"
}

data "github_release" "Release" {
  repository  = data.github_repository.Repo.name
  owner       = split("/", data.github_repository.Repo.full_name)[0]
  retrieve_by = "latest"
}

resource "nomad_job" "Pomerium" {
  jobspec = templatefile("${path.module}/Job.hcl", {
    Services = var.Services

    TLS = var.TLS

    YAMLConfigs = {
      Authenticate = templatefile("${path.module}/Configs/PomeriumAuthenicate.yaml", {
        Secrets = var.Secrets
        OpenID = var.OpenID
      })
      Authorize = templatefile("${path.module}/Configs/PomeriumAuthorize.yaml", {
        Secrets = var.Secrets
        OpenID = var.OpenID
      })
      DataBroker = templatefile("${path.module}/Configs/PomeriumDataBroker.yaml", {
        Secrets = var.Secrets
        OpenID = var.OpenID
      })
      Proxy = templatefile("${path.module}/Configs/PomeriumProxy.yaml", {
        Secrets = var.Secrets
        OpenID = var.OpenID
      })
    }

    Version = "debug"
  })
}