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

data "github_repository" "Netbox" {
  full_name = "netbox-community/netbox"
}

data "github_release" "Netbox" {
  repository  = data.github_repository.Netbox.name
  owner       = split("/", data.github_repository.Netbox.full_name)[0]
  retrieve_by = "latest"
}

#
# Secrets
#

resource "random_password" "NetBoxSecret" {
  length           = 50
  special          = true
}

resource "random_password" "NetboxRedisPassword" {
  length           = 16
  special          = true
}

resource "random_password" "NetboxRedisCachePassword" {
  length           = 16
  special          = true
}

resource "nomad_job" "Netbox" {
  jobspec = templatefile("${path.module}/Jobs/NetboxServer.hcl", {
    Redis = {
      Password = random_password.NetboxRedisPassword.result
    }

    RedisCache = {
      Password = random_password.NetboxRedisCachePassword.result
    }

    Netbox = {
      SecretKey = random_password.NetBoxSecret.result

      AdminUsername = var.Admin.Username
      AdminEmail = var.Admin.Email
    }

    Database = var.Database

    Token = var.Token

    Version = data.github_release.Netbox.release_tag
  })
}
