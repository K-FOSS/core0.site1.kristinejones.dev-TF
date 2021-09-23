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
  address    = "core0.site1.kristianjones.dev:8500"
  datacenter = "dc1"
}


locals {
  Patroni = var.Patroni
}

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
# Authentik KV
#
# TODO: Move all this to Consul KV trigger Terraform Sync
#

data "consul_key_prefix" "PomeriumOID" {
  path_prefix = "authentik/apps/pomeriumproxy/"
}

#
# Ingress
#

#
# Web
#

resource "consul_config_entry" "WebSTUN" {
  name = "ingressweb-stuntcp-cont"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol = "tcp"
  })
}

resource "consul_config_entry" "WebSTUNServiceIntentions" {
  name = "ingressweb-stuntcp-cont"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "vps1-ingressgw1"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}

#
# CoTurn
# 

#
# CoTurn STUN
#

resource "consul_config_entry" "CoTurnSTUN" {
  name = "coturn-stun-cont"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol = "tcp"
  })
}


resource "consul_config_entry" "CoTurnSTUNServiceIntentions" {
  name = "coturn-stun-cont"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "ingressweb-stuntcp-cont"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}


#
# CoTurn Metrics
# 

resource "consul_config_entry" "CoTurnMetrics" {
  name = "coturn-metrics-cont"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol = "http"
  })
}

