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

provider "nomad" {
  address = "http://core0.site1.kristianjones.dev:4646"
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
# Grafana
#

resource "nomad_job" "Grafana" {
  jobspec = templatefile("${path.module}/Jobs/Grafana/main.hcl", {
    Config = templatefile("${path.module}/Jobs/Grafana/Configs/Grafana.ini", var.Grafana)
  })
}

#
# AAA
#

#
# Authentik
#

resource "random_string" "AuthentikSecretKey" {
  length           = 10
  special          = false
}

resource "nomad_job" "Authentik" {
  jobspec = templatefile("${path.module}/Jobs/Authentik/main.hcl", {
    Database = var.Authentik.Database
    SECRET_KEY = "${random_string.AuthentikSecretKey.result}"
  })
}


#
# Caddy Web Ingress
#

resource "nomad_job" "Ingress" {
  jobspec = templatefile("${path.module}/Jobs/Web/Web.hcl", {
    Consul = var.Ingress.Consul

    GoBetweenCONF = templatefile("${path.module}/Jobs/Web/Configs/gobetween.toml", { 
      Consul = var.Ingress.Consul
    })

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

#
# Pomerium
#

resource "nomad_job" "Pomerium" {
  jobspec = templatefile("${path.module}/Jobs/Pomerium/main.hcl", {
    CONFIG =  templatefile("${path.module}/Jobs/Pomerium/Configs/Pomerium.yaml", var.Pomerium)
  })
}

#
# CoTurn
#

resource "random_password" "CoTurnPassword" {
  length           = 20
  special          = false
}

resource "nomad_job" "CoTurn" {
  jobspec = templatefile("${path.module}/Jobs/CoTurn/main.hcl", {
    CONFIG =  templatefile("${path.module}/Jobs/CoTurn/Configs/turnserver.conf", {
      CoTurn = var.CoTurn.CoTurn
      Database = var.CoTurn.Database
      CLIPassword = random_password.CoTurnPassword.result
    })
  })
}
