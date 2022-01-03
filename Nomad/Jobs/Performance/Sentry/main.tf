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
  Sentry = {
    Image = {
      Repo = "registry.kristianjones.dev/cache/getsentry"

      Tag = "21.12.0"
    }

    Config = templatefile("${path.module}/Configs/Sentry/Config.yaml", {
      Database = var.Database

      S3 = var.S3 
    })
  }
}

resource "nomad_job" "SentryServerJobFile" {
  jobspec = templatefile("${path.module}/Jobs/SentryServer.hcl", {
    Sentry = local.Sentry
  })
}