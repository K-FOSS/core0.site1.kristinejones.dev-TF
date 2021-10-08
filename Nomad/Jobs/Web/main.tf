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

resource "random_password" "CoTurnPassword" {
  length           = 20
  special          = false
}

resource "nomad_job" "JobFile" {
  jobspec = templatefile("${path.module}/Job.hcl", {
    Consul = var.Consul

    GoBetweenCONF = templatefile("${path.module}/Configs/gobetween.toml", { 
      Consul = var.Consul
    })

    Caddyfile = templatefile("${path.module}/Configs/Caddyfile.json", { 
      Cloudflare = var.CloudFlare

      Consul = var.Consul
    }),
  })
}