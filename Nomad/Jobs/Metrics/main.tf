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
# cAdvisor
#

# data "github_repository" "Repo" {
#   full_name = "google/cadvisor"
# }

# data "github_release" "Release" {
#   repository  = data.github_repository.Repo.name
#   owner       = split("/", data.github_repository.Repo.full_name)[0]
#   retrieve_by = "latest"
# }


#
# Prometheus
#
# TODO: Get GitHub Cache Back working with Terraform
#

#
# Cortex
#

locals {
  Cortex = {
    AlertManager = {
      Config = templatefile("${path.module}/Configs/Cortex/AlertManager.yaml", {
        SMTP = var.SMTP
      })
    }

    YAMLConfig = templatefile("${path.module}/Configs/Cortex/Cortex.yaml", var.Cortex)

    Version = "master-cd29c23"
  }
}

#
# Alert Manager
#

resource "nomad_job" "CortexAlertManager" {
  jobspec = templatefile("${path.module}/Jobs/Cortex/CortexAlertManager.hcl", {
    Cortex = {
      AlertManager = {
        Config = templatefile("${path.module}/Configs/Cortex/AlertManager.yaml", {
          SMTP = var.SMTP
        })
      }

      Database = var.Cortex.Database

      YAMLConfig = templatefile("${path.module}/Configs/Cortex/Cortex.yaml", var.Cortex)

      Version = "master-cd29c23"
    }
  })
}

#
# Configs
#

resource "nomad_job" "CortexConfigs" {
  jobspec = templatefile("${path.module}/Jobs/Cortex/CortexConfigs.hcl", {
    Cortex = {
      AlertManager = {
        Config = templatefile("${path.module}/Configs/Cortex/AlertManager.yaml", {
          SMTP = var.SMTP
        })
      }

      Database = var.Cortex.Database

      YAMLConfig = templatefile("${path.module}/Configs/Cortex/Cortex.yaml", var.Cortex)

      Version = "master-cd29c23"
    }
  })
}

#
# Distributor
# 

resource "nomad_job" "CortexDistributor" {
  jobspec = templatefile("${path.module}/Jobs/Cortex/CortexDistributor.hcl", {
    Cortex = {
      AlertManager = {
        Config = templatefile("${path.module}/Configs/Cortex/AlertManager.yaml", {
          SMTP = var.SMTP
        })
      }

      Database = var.Cortex.Database

      YAMLConfig = templatefile("${path.module}/Configs/Cortex/Cortex.yaml", var.Cortex)

      Version = "master-cd29c23"
    }
  })
}

#
# Ingester
#

resource "nomad_job" "CortexIngester" {
  jobspec = templatefile("${path.module}/Jobs/Cortex/CortexIngester.hcl", {
    Cortex = {
      AlertManager = {
        Config = templatefile("${path.module}/Configs/Cortex/AlertManager.yaml", {
          SMTP = var.SMTP
        })
      }

      Database = var.Cortex.Database

      YAMLConfig = templatefile("${path.module}/Configs/Cortex/Cortex.yaml", var.Cortex)

      Version = "master-cd29c23"
    }
  })
}

#
# Querier
#

resource "nomad_job" "CortexQuerier" {
  jobspec = templatefile("${path.module}/Jobs/Cortex/CortexQuerier.hcl", {
    Cortex = {
      AlertManager = {
        Config = templatefile("${path.module}/Configs/Cortex/AlertManager.yaml", {
          SMTP = var.SMTP
        })
      }

      Database = var.Cortex.Database

      YAMLConfig = templatefile("${path.module}/Configs/Cortex/Cortex.yaml", var.Cortex)

      Version = "master-cd29c23"
    }
  })
}

#
# Query Frontend
#

resource "nomad_job" "CortexQueryFrontend" {
  jobspec = templatefile("${path.module}/Jobs/Cortex/CortexQueryFrontend.hcl", {
    Cortex = {
      AlertManager = {
        Config = templatefile("${path.module}/Configs/Cortex/AlertManager.yaml", {
          SMTP = var.SMTP
        })
      }

      Database = var.Cortex.Database

      YAMLConfig = templatefile("${path.module}/Configs/Cortex/Cortex.yaml", var.Cortex)

      Version = "master-cd29c23"
    }
  })
}

#
# Query Scheduler
#

resource "nomad_job" "CortexQueryScheduler" {
  jobspec = templatefile("${path.module}/Jobs/Cortex/CortexQueryScheduler.hcl", {
    Cortex = {
      AlertManager = {
        Config = templatefile("${path.module}/Configs/Cortex/AlertManager.yaml", {
          SMTP = var.SMTP
        })
      }

      Database = var.Cortex.Database

      YAMLConfig = templatefile("${path.module}/Configs/Cortex/Cortex.yaml", var.Cortex)

      Version = "master-cd29c23"
    }
  })
}

#
# Ruler
#

resource "nomad_job" "CortexRuler" {
  jobspec = templatefile("${path.module}/Jobs/Cortex/CortexRuler.hcl", {
    Cortex = {
      AlertManager = {
        Config = templatefile("${path.module}/Configs/Cortex/AlertManager.yaml", {
          SMTP = var.SMTP
        })
      }

      Database = var.Cortex.Database

      YAMLConfig = templatefile("${path.module}/Configs/Cortex/Cortex.yaml", var.Cortex)

      Version = "master-cd29c23"
    }
  })
}

#
# Store Gateway
#

resource "nomad_job" "CortexStoreGateway" {
  jobspec = templatefile("${path.module}/Jobs/Cortex/CortexStoreGateway.hcl", {
    Cortex = {
      AlertManager = {
        Config = templatefile("${path.module}/Configs/Cortex/AlertManager.yaml", {
          SMTP = var.SMTP
        })
      }

      Database = var.Cortex.Database

      YAMLConfig = templatefile("${path.module}/Configs/Cortex/Cortex.yaml", var.Cortex)

      Version = "master-cd29c23"
    }
  })
}

#
# Compactor
#

resource "nomad_job" "CortexCompactor" {
  jobspec = templatefile("${path.module}/Jobs/Cortex/CortexCompactor.hcl", {
    Cortex = {
      AlertManager = {
        Config = templatefile("${path.module}/Configs/Cortex/AlertManager.yaml", {
          SMTP = var.SMTP
        })
      }

      Database = var.Cortex.Database

      YAMLConfig = templatefile("${path.module}/Configs/Cortex/Cortex.yaml", var.Cortex)

      Version = "master-cd29c23"
    }
  })
}

#
# Prometheus
#

resource "nomad_job" "PrometheusJob" {
  jobspec = templatefile("${path.module}/Jobs/Prometheus.hcl", {
    Prometheus = {
      YAMLConfig = templatefile("${path.module}/Configs/Prometheus/Prometheus.yaml", {
        CoreVault = var.Prometheus.CoreVault
        Vault = var.Prometheus.Vault

        iDRAC = {
          Devices = var.iDRAC.Devices
        }
      })

      Grafana = var.Prometheus.Grafana

      Version = "v2.30.0"
    }
  })
}

#
# StarLink Exporter
#

resource "nomad_job" "StarLinkJob" {
  jobspec = templatefile("${path.module}/Jobs/StarLink.hcl", {
    StarLink = {
      IPAddress = "192.168.100.1"

      Port = "9200"

      Version = "latest"
    }
  })
}

#
# MikroTik Exporter
# 
resource "nomad_job" "MikroTikJob" {
  jobspec = templatefile("${path.module}/Jobs/MikroTik.hcl", {
    MikroTik = {
      Config = templatefile("${path.module}/Configs/MikroTik/Config.yaml", {
        Devices = var.MikroTik.Devices
      })

      Version = "1.0.12-DEVEL"
    }
  })
}

#
# PostgreSQL Exporter
#
# resource "nomad_job" "PostgreSQLJob" {
#   jobspec = templatefile("${path.module}/Jobs/PostgreSQL.hcl", {
#     PostgreSQL = {
#       Config = templatefile("${path.module}/Configs/MikroTik/Config.yaml", {
#         Devices = var.MikroTik.Devices
#       })

#       Version = "1.0.12-DEVEL"
#     }
#   })
# }

#
# iDRAC Exporter
#

resource "nomad_job" "iDRACJobFile" {
  jobspec = templatefile("${path.module}/Jobs/iDRAC.hcl", {
    iDRAC = {
      Username = var.iDRAC.Username
      Password = var.iDRAC.Password
    }
  })
}

#
# cAdvisor
#

resource "nomad_job" "cAdvisorJobFile" {
  jobspec = templatefile("${path.module}/Jobs/cAdvisor.hcl", {
    cAdvisor = {
      Version = "v0.43.0"
    }
  })
}

#
# Alerts and Notification Systems
#

#
# MSTeams
#
resource "nomad_job" "MSTeamsJobFile" {
  jobspec = templatefile("${path.module}/Jobs/TeamsAlert.hcl", {
    Teams = {
      Webhook = var.MSTeams.Webhook
    }
  })
}