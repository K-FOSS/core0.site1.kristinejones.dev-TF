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

resource "random_id" "OutlineSecretKey" {
  byte_length = 32
}

resource "random_id" "OutlineUtilsSecretKey" {
  byte_length = 32
}


#
# Config
#
locals {
  Outline = {
    Database = var.Database

    OpenID = var.OpenID

    S3 = var.S3

    Secrets = {
      SecretKey = random_id.OutlineSecretKey.hex
      UtilsSecretKey = random_id.OutlineUtilsSecretKey.hex
    }

    Version = "0.60.3"
  }
}

#
# Server
#
resource "nomad_job" "OutlineServerJobFile" {
  jobspec = templatefile("${path.module}/Jobs/OutlineServer.hcl", {
    Outline = local.Outline
  })
}
