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
  }
}

provider "nomad" {
  address = "https://nomad.kristianjones.dev:443"
  region  = "global"
}

resource "nomad_job" "Nomad" {
  jobspec = templatefile("${path.module}/Jobs/Bitwarden.hcl", {
    Database = var.Bitwarden.Database
  })
}