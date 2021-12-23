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

    CA = var.OpenSearch.TLS.CA

    EntryScript = file("${path.module}/Configs/OpenSearch/Entry.sh")

    TLS = {
      for Key, Item in var.OpenSearch.TLS : Key => Item
      if Key != "CA" 
    }

    Config = templatefile("${path.module}/Configs/OpenSearch/Config.yaml", {
      S3 = var.OpenSearch.S3
    })

    JVMOptions = file("${path.module}/Configs/OpenSearch/jvm.options")

    Log4JConfig = file("${path.module}/Configs/OpenSearch/log4j2.properties")
  }

  Unigraph = {
    Version = ""
  }
}

resource "nomad_job" "OpenSearchMainJobFile" {
  jobspec = templatefile("${path.module}/Jobs/OpenSearchMain.hcl", {
    OpenSearch = local.OpenSearch
  })
}

resource "nomad_job" "OpenSearchIngestJobFile" {
  jobspec = templatefile("${path.module}/Jobs/OpenSearchIngest.hcl", {
    OpenSearch = local.OpenSearch
  })
}

#
# Dashboard
#
resource "nomad_job" "OpenSearchDashboardrdJobFile" {
  jobspec = templatefile("${path.module}/Jobs/OpenSearchDashboard.hcl", {
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