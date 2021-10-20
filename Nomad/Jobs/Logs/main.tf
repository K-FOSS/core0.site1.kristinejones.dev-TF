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

data "github_repository" "VectorRepo" {
  full_name = "vectordotdev/vector"
}

data "github_release" "VectorRelease" {
  repository  = data.github_repository.VectorRepo.name
  owner       = split("/", data.github_repository.VectorRepo.full_name)[0]
  retrieve_by = "latest"
}

resource "random_password" "Secret" {
  length           = 50
  special          = true
}

resource "nomad_job" "LogsJobFile" {
  jobspec = templatefile("${path.module}/Job.hcl", {
    Config = templatefile("${path.module}/Configs/Grafana.ini", {
      Database = var.Database

      SecretKey = random_password.Secret.result
    })

    Vector = {
      Config = templatefile("${path.module}/Configs/Vector/Vector.yaml", {

      })

      Version = split("v", data.github_release.VectorRelease.release_tag)[1]
    }

    TLS = var.TLS

    #
    # TODO: Change back to split("v", data.github_release.Release.release_tag)[1] once https://github.com/grafana/grafana/pull/37765 is released on prod
    #
    Version = "main"
  })
}