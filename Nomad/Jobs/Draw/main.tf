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

data "github_repository" "ExcalidrawRepo" {
  full_name = "grafana/grafana"
}

data "github_release" "ExcalidrawRelease" {
  repository  = data.github_repository.ExcalidrawRepo.name
  owner       = split("/", data.github_repository.ExcalidrawRepo.full_name)[0]
  retrieve_by = "latest"
}

resource "nomad_job" "ExcalidrawJobFile" {
  jobspec = templatefile("${path.module}/Jobs/Excalidraw.hcl", {
    Version = "main"
  })
}

# data "github_repository" "DrawIORepo" {
#   full_name = "grafana/grafana"
# }

# data "github_release" "DrawIORelease" {
#   repository  = data.github_repository.DrawIORepo.name
#   owner       = split("/", data.github_repository.DrawIORepo.full_name)[0]
#   retrieve_by = "latest"
# }

# resource "nomad_job" "ExcalidrawJobFile" {
#   jobspec = templatefile("${path.module}/Jobs/DrawIO.hcl", {
#     Version = "main"
#   })
# }