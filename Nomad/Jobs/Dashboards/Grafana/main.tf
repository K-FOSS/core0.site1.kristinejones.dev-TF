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

# data "github_repository" "Repo" {
#   full_name = "grafana/grafana"
# }

# data "github_release" "Release" {
#   repository  = data.github_repository.Repo.name
#   owner       = split("/", data.github_repository.Repo.full_name)[0]
#   retrieve_by = "latest"
# }

resource "random_password" "Secret" {
  length = 50
  special = true
}

resource "nomad_job" "Grafana" {
  jobspec = templatefile("${path.module}/Jobs/Grafana.hcl", {
    Config = templatefile("${path.module}/Configs/Grafana.ini", {
      Database = var.Database

      SecretKey = random_password.Secret.result
    })

    TLS = var.TLS

    #
    # TODO: Change back to split("v", data.github_release.Release.release_tag)[1] once https://github.com/grafana/grafana/pull/37765 is released on prod
    #
    Version = "main"
  })
}