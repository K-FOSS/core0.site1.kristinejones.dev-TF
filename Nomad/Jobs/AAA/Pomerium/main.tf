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

# data "github_repository" "Repo" {
#   full_name = "pomerium/pomerium"
# }

# data "github_release" "Release" {
#   repository  = data.github_repository.Repo.name
#   owner       = split("/", data.github_repository.Repo.full_name)[0]
#   retrieve_by = "latest"
# }

locals {
  LogLevel = "DEBUG"
  

  Pomerium = {
    Routes = base64encode(templatefile("${path.module}/Configs/Pomerium/Routes.yaml", {}))
    
    Image = {
      Repo = "registry.kristianjones.dev/cache/"

      Tag = "v0.15.6"
    }
  }

  

  Tracing = {
    SampleRate = "0.20"
  }
}

#
# Authenticate
#

resource "nomad_job" "PomeriumAuthenticateJobFile" {
  jobspec = templatefile("${path.module}/Jobs/PomeriumAuthenticate.hcl", {
    Pomerium = local.Pomerium

    TLS = {
      Redis = var.TLS.Redis

      Metrics = var.TLS.Authenticate.Metrics

      Server = var.TLS.Authenticate.Server

      Grafana = var.TLS.Grafana
      HomeAssistant = var.TLS.HomeAssistant
      GitLab = var.TLS.GitLab
    }

    Config = templatefile("${path.module}/Configs/Pomerium/PomeriumAuthenticate.yaml", {
      Secrets = var.Secrets
      OpenID = var.OpenID
    })
  })
}

#
# Authorize
#

resource "nomad_job" "PomeriumAuthorizeJobFile" {
  jobspec = templatefile("${path.module}/Jobs/PomeriumAuthorize.hcl", {
    Pomerium = local.Pomerium

    TLS = {
      Redis = var.TLS.Redis

      Metrics = var.TLS.Authorize.Metrics

      Server = var.TLS.Authorize.Server

      Grafana = var.TLS.Grafana
      HomeAssistant = var.TLS.HomeAssistant
      GitLab = var.TLS.GitLab
    }

    Config = templatefile("${path.module}/Configs/Pomerium/PomeriumAuthorize.yaml", {
      Secrets = var.Secrets
      OpenID = var.OpenID
    })
  })
}

#
# Data Broker
#

resource "nomad_job" "PomeriumDataBrokerJobFile" {
  jobspec = templatefile("${path.module}/Jobs/PomeriumDataBroker.hcl", {
    Pomerium = local.Pomerium

    TLS = {
      Redis = var.TLS.Redis

      Metrics = var.TLS.DataBroker.Metrics

      Server = var.TLS.DataBroker.Server

      Grafana = var.TLS.Grafana
      HomeAssistant = var.TLS.HomeAssistant
      GitLab = var.TLS.GitLab
    }

    Config = templatefile("${path.module}/Configs/Pomerium/PomeriumDataBroker.yaml", {
      Secrets = var.Secrets
      OpenID = var.OpenID
    })
  })
}


#
# Proxy
#

resource "nomad_job" "PomeriumProxyJobFile" {
  jobspec = templatefile("${path.module}/Jobs/PomeriumProxy.hcl", {
    Pomerium = local.Pomerium

    TLS = {
      Redis = var.TLS.Redis

      Metrics = var.TLS.Proxy.Metrics

      Server = var.TLS.Proxy.Server

      Grafana = var.TLS.Grafana
      HomeAssistant = var.TLS.HomeAssistant
      GitLab = var.TLS.GitLab
    }

    Config = templatefile("${path.module}/Configs/Pomerium/PomeriumProxy.yaml", {
      Secrets = var.Secrets
      OpenID = var.OpenID
    })
  })
}