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

resource "random_id" "MattermostAtRestKey" {
  byte_length = 32
}

resource "random_id" "MattermostGitLabKey" {
  byte_length = 16
}



locals {
  Mattermost = {
    Config = templatefile("${path.module}/Configs/Mattermost/config.json", {
      Database = var.Database

      SMTP = var.SMTP

      S3 = var.S3

      Secrets = {
        EncryptionKey = random_id.MattermostAtRestKey.hex
        GitLab = random_id.MattermostGitLabKey.hex
      }

      GitLab = {
        ClientID = var.GitLab.ClientID
        ClientSecret = var.GitLab.ClientSecret

        URL = "https://gitlab.kristianjones.dev"
      }

    })

    Version = "release-6.2"
  }

}

resource "nomad_job" "Mattermost" {
  jobspec = templatefile("${path.module}/Jobs/MattermostLeader.hcl", {
    Mattermost = local.Mattermost
  })
}