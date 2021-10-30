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

resource "random_password" "TinkAdminPassword" {
  length           = 50
  special          = true
}

locals {
  TinkAdmin = {
    Username = "tink"
    Password = random_password.TinkAdminPassword.result
  }
}

resource "nomad_job" "Tinkerbell" {
  jobspec = templatefile("${path.module}/Job.hcl", {
    Database = var.Database

    TLS = var.TLS

    Version = "latest"

    Admin = local.TinkAdmin

    Boots = var.Boots

    UploadScript =  file("${path.module}/Configs/Upload.sh")

    Images =  file("${path.module}/Configs/Images.txt")
  })
}