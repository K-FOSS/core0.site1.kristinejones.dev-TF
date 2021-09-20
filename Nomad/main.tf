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

#
# Bitwarden
#
resource "nomad_job" "Nomad" {
  jobspec = templatefile("${path.module}/Jobs/Bitwarden/Bitwarden.hcl", {
    Database = var.Bitwarden.Database
  })
}

#
# Caddy Web Ingress
#

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
# Grafana
#

# resource "nomad_job" "Grafana" {
#   jobspec = templatefile("${path.module}/Jobs/Web/Web.hcl", {
#     Consul = var.Ingress.Consul

#     CONFIG = templatefile("${path.module}/Jobs/Grafana/Configs/Grafana.ini", { 
#       Database = var.
#     }),
#   })
# }

#
# Patroni
#

resource "nomad_volume" "Patroni" {
  type                  = "csi"
  plugin_id             = "truenas"
  volume_id             = "patronidata-vol"
  name                  = "patronidata-vol"
  external_id           = "test-vol"

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }

  deregister_on_destroy = true

  mount_options {
    fs_type = "nfs"
    mount_flags = ["nolock"]
  }

  context = {
    node_attach_driver = "nfs"
    provisioner_driver = "freenas-nfs"
    server             = "172.16.51.21"
    share              = "/mnt/Site1.NAS1.Pool1/CSI/vols/test-vol"
  }
}

resource "nomad_job" "Patroni" {
  jobspec = templatefile("${path.module}/Jobs/Patroni/main.hcl", {
    Volume = nomad_volume.Patroni
    CONFIG =  templatefile("${path.module}/Jobs/Patroni/Configs/Patroni.yaml", var.Patroni)
  })
}

#
# Database Web Interfaces
#

# locals {
#   Databases = tomap({
#     Keycloak = {
#       target = "distributor"
#       replicas = 3
#       name = "Distributor"
#     },
#     Ingester = {
#       target = "ingester"
#       replicas = 3
#       name = "Ingester"
#     }, 
#   })
# }

# resource "nomad_job" "DatabaseWeb" {
#   for_each = local.Databases

#   jobspec = templatefile("${path.module}/Jobs/DatabaseWeb/main.hcl", {
#     Consul = var.Ingress.Consul

#     CONFIG = templatefile("${path.module}/Jobs/Grafana/Configs/Grafana.ini", { 
#       Database = var.
#     }),
#   })
# }

#
# TODO: Move this to VPS1 Stack
# 
# This is temporary so I can more easily migrate services over
#

resource "nomad_job" "VPS1-Ingress" {
  jobspec = file("${path.module}/Jobs/VPS1-Ingress/Web.hcl")
}