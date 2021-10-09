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
  full_name = "processone/ejabberd"
}

data "github_release" "Release" {
  repository  = data.github_repository.Repo.name
  owner       = split("/", data.github_repository.Repo.full_name)[0]
  retrieve_by = "latest"
}

#
# Secrets
#

resource "random_password" "RedisPassword" {
  length           = 32
  special          = true
}

resource "nomad_job" "JobFile" {
  jobspec = templatefile("${path.module}/Job.hcl", {
    eJabberD = {
      Config = templatefile("${path.module}/Configs/eJabberD.yaml", {
        Database = var.Database

        Redis = {
          Hostname = "ejabberd-redis.service.kjdev"
          Port = "6379"

          Password = random_password.RedisPassword.result
        }
      })
    }

    TLS = var.TLS

    Redis = {
      Password = random_password.RedisPassword.result
    }


    Version = data.github_release.Release.release_tag
  })
}
