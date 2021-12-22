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

#
# Database
#
data "http" "PSQLFile" {
  url = "https://raw.githubusercontent.com/processone/ejabberd/21.07/sql/pg.new.sql"
}

#
# Secrets
#

resource "random_password" "RedisPassword" {
  length = 32
  special = true
}

resource "random_password" "eJabberDCookie" {
  length = 32
  special = true
}

locals {
  eJabberD = {
    Image = {
      Repo = ""
      
      Tag = "21.07"
    }

    Database = var.Database

    DatabaseInit = data.http.PSQLFile.body

    TLS = var.TLS

    Secrets = {
      eJabberDCookie = random_password.eJabberDCookie.result
    }

    Config = templatefile("${path.module}/Configs/eJabberD.yaml", {
      Database = var.Database

      Redis = {
        Hostname = "redis.ejabberd.service.kjdev"
        Port = "6379"

        Password = random_password.RedisPassword.result
      }
    })
  }
}

resource "nomad_job" "eJabberDMQTTJobFile" {
  jobspec = templatefile("${path.module}/Jobs/MQTT.hcl", {
    eJabberD = local.eJabberD
  })
}
