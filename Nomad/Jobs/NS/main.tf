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

data "http" "PSQLFile" {
  url = "https://raw.githubusercontent.com/PowerDNS/pdns/rel/auth-4.5.x/modules/gpgsqlbackend/schema.pgsql.sql"
}

resource "nomad_job" "NSJobFile" {
  jobspec = templatefile("${path.module}/JobFile.hcl", {
    PowerDNS = {
      PSQL = data.http.PSQLFile.body
      Database = var.PowerDNS.Database

      Config = templatefile("${path.module}/Configs/PowerDNS/pdns.conf", {
        Database = var.PowerDNS.Database
      })
    }
  })
}