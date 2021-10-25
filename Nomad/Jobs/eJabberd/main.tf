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
# Database
#
data "http" "PSQLFile" {
  url = "https://raw.githubusercontent.com/processone/ejabberd/21.07/sql/pg.new.sql"
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
    PSQL_INIT = data.http.PSQLFile.body

    Database = var.Database

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


    Version = "21.07"
  })
}
