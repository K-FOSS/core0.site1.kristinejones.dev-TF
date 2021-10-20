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

resource "nomad_job" "LogsJobFile" {
  jobspec = templatefile("${path.module}/Job.hcl", {
    Vector = {
      Config = templatefile("${path.module}/Configs/Vector/Vector.yaml", {

      })

      Version = split("v", data.github_release.VectorRelease.release_tag)[1]
    }
  })
}