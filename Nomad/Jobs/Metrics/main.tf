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

resource "nomad_job" "CortexJob" {
  jobspec = templatefile("${path.module}/Jobs/Cortex.hcl", {
    Cortex = {
      Targets = var.Cortex.Targets

      Database = var.Cortex.Database

      YAMLConfig = templatefile("${path.module}/Configs/Cortex.yaml", var.Cortex)

      Version = "master-85c3781"
    }
  })
}

resource "nomad_job" "PrometheusJob" {
  jobspec = templatefile("${path.module}/Jobs/Prometheus.hcl", {
    Prometheus = {
      YAMLConfig = templatefile("${path.module}/Configs/Prometheus.yaml", {
        CoreVault = var.Prometheus.CoreVault
        Vault = var.Prometheus.Vault
      })

      Grafana = var.Prometheus.Grafana

      Version = "v2.30.0"
    }
  })
}

resource "nomad_job" "StarLinkJob" {
  jobspec = templatefile("${path.module}/Jobs/StarLink.hcl", {
    StarLink = {
      IPAddress = "192.168.100.1"

      Port = "9200"

      Version = "latest"
    }
  })
}