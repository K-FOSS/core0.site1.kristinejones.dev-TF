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
  full_name = "isc-projects/kea"
}

data "github_release" "Release" {
  repository  = data.github_repository.Repo.name
  owner       = split("/", data.github_repository.Repo.full_name)[0]
  retrieve_by = "latest"
}

data "http" "PSQLFile" {
  url = "https://raw.githubusercontent.com/isc-projects/kea/${data.github_release.Release.release_tag}/src/share/database/scripts/pgsql/dhcpdb_create.pgsql"
}

resource "nomad_job" "JobFile" {
  jobspec = templatefile("${path.module}/Job.hcl", {
    PSQL_INIT = data.http.PSQLFile.body
    Database = var.Database

    DHCP4 = {
      Config = templatefile("${path.module}/Configs/DHCP4.jsonc", {
        Database = var.Database
      })
    }

    DHCP6 = {
      Config = templatefile("${path.module}/Configs/DHCP6.jsonc", {
        Database = var.Database
      })
    }

    KeaCTRL = {
      Config = templatefile("${path.module}/Configs/keactrl.conf", {})
      AgentConfig = templatefile("${path.module}/Configs/kea-ctrl-agent.jsonc", {})
    }

    EntryScript = templatefile("${path.module}/Configs/kea-ctrl-agent.jsonc", {})
  })
}