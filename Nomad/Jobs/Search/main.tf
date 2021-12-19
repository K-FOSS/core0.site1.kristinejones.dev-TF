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

locals {
  OpenSearch = {
    Image = {
      Repo = "registry.kristianjones.dev/cache/opensearchproject"

      Tag = "1.2.0"
    }

    TLS = {
      for Key, Item in var.OpenSearch.TLS : Key => Item
      if Key != "CA" 
    }

    Config = templatefile("${path.module}/Configs/OpenSearch/Config.yaml", {
      S3 = var.OpenSearch.S3
    })
  }

  Unigraph = {
    Version = ""
  }
}

resource "nomad_job" "OpenSearchCoordinatorJobFile" {
  jobspec = templatefile("${path.module}/Jobs/OpenSearchCoordinator.hcl", {
    OpenSearch = local.OpenSearch
  })
}

# resource "nomad_job" "UnigraphJobFile" {
#   jobspec = templatefile("${path.module}/Jobs/GoBetween.hcl", {
#     Consul = var.GoBetween.Consul

#     GoBetween = {
#       Config = templatefile("${path.module}/Configs/GoBetween/Config.json", {
#         Consul = var.GoBetween.Consul
#       })
#     }
    
#   })
# }