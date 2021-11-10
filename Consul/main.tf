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

provider "consul" {
  address = "consul.service.dc1.kjdev:8500"
  datacenter = "dc1"
}

locals {
  Patroni = var.Patroni

  #
  # Grafana Cortex
  #
  Cortex = var.Cortex

  #
  # Grafana Loki
  #
  Loki = var.Loki

  #
  # Grafana Tempo
  #
  Tempo = var.Tempo
}

#
# Patroni Token & Service
#


resource "random_uuid" "PatroniToken" { }


resource "consul_acl_policy" "PatroniACL" {
  name  = local.Patroni.ServiceName

  rules = templatefile("${path.module}/ACLs/Patroni.hcl", local.Patroni)
}

resource "consul_acl_token" "PatroniToken" {
  accessor_id = random_uuid.PatroniToken.result

  description = "Patroni PostgreSQL Database"

  policies = ["${consul_acl_policy.PatroniACL.name}"]
  local = true
}

data "consul_acl_token_secret_id" "PatroniToken" {
  accessor_id = consul_acl_token.PatroniToken.id
}

#
# TODO: Make this shit a compostable module
#

#
# Grafana Cortex
#

resource "random_uuid" "CortexToken" { }


resource "consul_acl_policy" "CortexACL" {
  name  = "GrafanaCortexACL"

  rules = templatefile("${path.module}/ACLs/KVTemplate.hcl", local.Cortex)
}

resource "consul_acl_token" "CortexToken" {
  accessor_id = random_uuid.CortexToken.result

  description = "Grafana Cortex Long term Time series storage automation"

  policies = ["${consul_acl_policy.CortexACL.name}"]
  local = true
}

data "consul_acl_token_secret_id" "CortexToken" {
  accessor_id = consul_acl_token.CortexToken.id
}

#
# Grafana Loki
#

resource "random_uuid" "LokiToken" { }


resource "consul_acl_policy" "LokiACL" {
  name  = "GrafanaLokiACL"

  rules = templatefile("${path.module}/ACLs/KVTemplate.hcl", local.Loki)
}

resource "consul_acl_token" "LokiToken" {
  accessor_id = random_uuid.LokiToken.result

  description = "Grafana Loki Long term Time series storage automation"

  policies = ["${consul_acl_policy.LokiACL.name}"]
  local = true
}

data "consul_acl_token_secret_id" "LokiToken" {
  accessor_id = consul_acl_token.LokiToken.id
}

#
# Grafana Tempo
# 

resource "random_uuid" "TempoToken" { }


resource "consul_acl_policy" "TempoACL" {
  name  = "GrafanaTempoACL"

  rules = templatefile("${path.module}/ACLs/KVTemplate.hcl", local.Tempo)
}

resource "consul_acl_token" "TempoToken" {
  accessor_id = random_uuid.TempoToken.result

  description = "Grafana Tempo Long term Time series storage automation"

  policies = ["${consul_acl_policy.TempoACL.name}"]
  local = true
}

data "consul_acl_token_secret_id" "TempoToken" {
  accessor_id = consul_acl_token.TempoToken.id
}

#
# DNS
#
# CoreDNS Consul consul_catalog plugin
#

resource "random_uuid" "DNSToken" { }


resource "consul_acl_policy" "DNSACL" {
  name  = "DNSACL"

  rules = templatefile("${path.module}/ACLs/CoreDNS.hcl", {})
}

resource "consul_acl_token" "DNSToken" {
  accessor_id = random_uuid.DNSToken.result

  description = "CoreDNS Consul Catalog Plugin"

  policies = ["${consul_acl_policy.DNSACL.name}"]
  local = true
}

data "consul_acl_token_secret_id" "DNSToken" {
  accessor_id = consul_acl_token.DNSToken.id
}

#
# Consul Backups
#

resource "random_uuid" "BackupsToken" { }


resource "consul_acl_policy" "BackupsACL" {
  name  = "BackupsACL"

  rules = templatefile("${path.module}/ACLs/Backups.hcl", {})
}

resource "consul_acl_token" "BackupsToken" {
  accessor_id = random_uuid.BackupsToken.result

  description = "Consul Backups ACL"

  policies = ["${consul_acl_policy.BackupsACL.name}"]
  local = true
}

data "consul_acl_token_secret_id" "BackupsToken" {
  accessor_id = consul_acl_token.BackupsToken.id
}

#
# GoBetween
#

resource "random_uuid" "GoBetweenToken" { }


resource "consul_acl_policy" "GoBetweenACL" {
  name  = "GoBetween"

  rules = templatefile("${path.module}/ACLs/GoBetween.hcl", {})
}

resource "consul_acl_token" "GoBetweenToken" {
  accessor_id = random_uuid.GoBetweenToken.result

  description = "GoBetween Consul Catalog Plugin"

  policies = ["${consul_acl_policy.GoBetweenACL.name}"]
  local = true
}

data "consul_acl_token_secret_id" "GoBetweenToken" {
  accessor_id = consul_acl_token.GoBetweenToken.id
}


#
# Authentik KV
#
# TODO: Move all this to Consul KV trigger Terraform Sync
#

data "consul_key_prefix" "PomeriumOID" {
  path_prefix = "authentik/apps/pomeriumproxy/"
}

data "consul_key_prefix" "eJabberDOID" {
  path_prefix = "authentik/apps/pomeriumproxy/"
}

#
# TODO: Export Randomly generated security keys to Consul for Grafana to link up with secure RBAC access to allow for easiler management of DB, Vault, TLS, Redis, ETC
#
resource "consul_key_prefix" "HASS" {
  datacenter = "dc1"

  # Prefix to add to prepend to all of the subkey names below.
  path_prefix = "TLS/HomeAssistant/"

  subkeys = {
    "CA" = var.HomeAssistant.TLS.CA
    "Cert" = var.HomeAssistant.TLS.Cert
    "Key" = var.HomeAssistant.TLS.Key
  }
}