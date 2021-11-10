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
# Secrets
#

#
# Harbor Core
#
resource "random_password" "HarborCoreSecret" {
  length = 50
  special = true
}

#
# Harbor Job Service
#
resource "random_password" "HarborJobServiceSecret" {
  length = 50
  special = true
}

locals {
  Harbor = {
    Secrets = {
      Core = random_password.HarborCoreSecret.result
      JobService = random_password.HarborJobServiceSecret.result
    }
  }
}

resource "nomad_job" "HarborCoreJobFile" {
  jobspec = templatefile("${path.module}/Jobs/HarborCore.hcl", {
    EntryScript = file("${path.module}/Configs/HarborCore/Entry.sh")

    Harbor = {
      Secrets = local.Harbor.Secrets

      TLS = {
        CA = var.Harbor.TLS.CA

        Cert = var.Harbor.TLS.Core.Cert
        Key = var.Harbor.TLS.Core.Key
      }

      Database = var.Harbor.Database

      Config =  templatefile("${path.module}/Configs/HarborCore/app.conf", {
      })

      Version = "v2.4.0-dev"
    }
  })
}

resource "nomad_job" "HarborJobServiceJobFile" {
  jobspec = templatefile("${path.module}/Jobs/HarborJobService.hcl", {
    EntryScript = file("${path.module}/Configs/HarborJobService/Entry.sh")

    Harbor = {
      Secrets = local.Harbor.Secrets

      TLS = {
        CA = var.Harbor.TLS.CA

        Cert = var.Harbor.TLS.JobService.Cert
        Key = var.Harbor.TLS.JobService.Key
      }

      Config =  templatefile("${path.module}/Configs/HarborJobService/Config.yaml", {
      })

      Version = "v2.4.0-dev"
    }
  })
}

resource "nomad_job" "HarborPortalJobFile" {
  jobspec = templatefile("${path.module}/Jobs/HarborPortal.hcl", {
    EntryScript = file("${path.module}/Configs/HarborPortal/Entry.sh")

    Harbor = {
      TLS = {
        CA = var.Harbor.TLS.CA

        Cert = var.Harbor.TLS.Portal.Cert
        Key = var.Harbor.TLS.Portal.Key
      }

      Config =  templatefile("${path.module}/Configs/HarborPortal/NGINX.conf", {
      })

      Version = "v2.4.0-dev"
    }
  })
}

resource "nomad_job" "HarborRegistryJobFile" {
  jobspec = templatefile("${path.module}/Jobs/HarborRegistry.hcl", {
    EntryScript = file("${path.module}/Configs/HarborRegistry/Entry.sh")

    Harbor = {
      Secrets = local.Harbor.Secrets

      TLS = {
        CA = var.Harbor.TLS.CA

        Cert = var.Harbor.TLS.Registry.Cert
        Key = var.Harbor.TLS.Registry.Key
      }

      Config =  templatefile("${path.module}/Configs/HarborRegistry/Config.yaml", {
        S3 = var.Harbor.S3
      })

      Version = "v2.4.0-dev"
    }
  })
}