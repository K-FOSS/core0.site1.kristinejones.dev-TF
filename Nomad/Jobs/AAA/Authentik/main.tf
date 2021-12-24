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
  Authentik = {
    Image = {
      Repo = "ghcr.io/goauthentik"

      Tag = "2021.12.4"
    }

    Secrets = {
      SecretKey = var.Secrets.SecretKey
    }

    Domain = var.Domain

    S3 = var.S3

    Database = var.Database

    SMTP = var.SMTP
  }
}

#
# Authentik Server
#

resource "nomad_job" "AuthentikServerJobFile" {
  jobspec = templatefile("${path.module}/Jobs/AuthentikServer.hcl", {
    Authentik = local.Authentik
  })
}

#
# Authentik Workers
#

resource "nomad_job" "AuthentikWorkerJobFile" {
  jobspec = templatefile("${path.module}/Jobs/AuthentikWorker.hcl", {
    Authentik = {
      SecretKey = var.Secrets.SecretKey
    }

    Database = var.Database

    SMTP = var.SMTP

    Version = "2021.12.2"
  })
}

#
# LDAP Outpost
#

resource "nomad_job" "AuthentikLDAPOutpostJobFile" {
  jobspec = templatefile("${path.module}/Jobs/AuthentikLDAP.hcl", {
    Authentik = {
      SecretKey = var.Secrets.SecretKey
    }

    LDAP = var.LDAP

    Database = var.Database

    SMTP = var.SMTP

    Version = "2021.12.3"
  })
}