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

locals {
  Memcached = merge(var, {
    Version = "1.6.12"
  })
}

resource "nomad_job" "ServiceMemCacheDJobFile" {
  jobspec = templatefile("${path.module}/Jobs/ServiceMemcached.hcl", local.Memcached)
}