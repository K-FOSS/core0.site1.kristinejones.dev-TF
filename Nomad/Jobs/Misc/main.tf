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

#
# CyberChef
#

resource "nomad_job" "CyberChefJobFile" {
  jobspec = templatefile("${path.module}/Jobs/CyberChef.hcl", {

  })
}

#
# Avatars
#

#
# Ivatar
#

# resource "nomad_job" "IvatarJobFile" {
#   jobspec = templatefile("${path.module}/Jobs/Ivatar.hcl", var.Ivatar)
# }


#
# ShareX
#
# TODO: Find a ShareX server with S3, OpenID, and Postgresql
#

locals {
  ShareX = {
    Image = {
      Repo = "linuxserver/xbackbone"

      Tag = "latest"
    }

    Config = templatefile("${path.module}/Configs/ShareX/config.php", var.ShareX)
  }
}

resource "nomad_job" "ShareXJobFile" {
  jobspec = templatefile("${path.module}/Jobs/ShareX.hcl", {
    ShareX = local.ShareX
  })
}