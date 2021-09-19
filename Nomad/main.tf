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
  jobspec = templatefile("${path.module}/Jobs/Bitwarden/Bitwarden.hcl", {
    Database = var.Bitwarden.Database
  })
}

resource "nomad_job" "Ingress" {
  jobspec = templatefile("${path.module}/Jobs/Web/Web.hcl", {
    Consul = var.Ingress.Consul

    Caddyfile = templatefile("${path.module}/Jobs/Web/Configs/Caddyfile.json", { 
      Cloudflare = var.Ingress.Cloudflare

      Consul = var.Ingress.Consul
    }),
  })
}

#
# TODO: Move this to VPS1 Stack
# 
# This is temporary so I can more easily migrate services over
#

resource "nomad_job" "VPS1-Ingress" {
  jobspec = file("${path.module}/Jobs/VPS1-Ingress/Web.hcl")
}