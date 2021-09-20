terraform {
  required_providers {
    #
    # Hashicorp Consul
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/consul/latest/docs
    #
    consul = {
      source = "hashicorp/consul"
      version = "2.13.0"
    }
  }
}

locals {
  Patroni = var.Patroni
}

resource "random_uuid" "PatroniToken" { }


resource "consul_acl_policy" "PatroniACL" {
  name  = "Patroni"

  rules = templatefile("${path.module}/ACLs/Patroni.hcl", local.Patroni)
}

resource "consul_acl_token" "PatroniToken" {
  accessor_id = random_uuid.CoreVaultToken.result

  description = "Patroni PostgreSQL Database"

  policies = ["${consul_acl_policy.CoreVaultACL.name}"]
  local = true
}

data "consul_acl_token_secret_id" "PatroniToken" {
  accessor_id = consul_acl_token.PatroniToken.id
}