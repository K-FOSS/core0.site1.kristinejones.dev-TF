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
  CORTEX_TARGETS = tomap({
    Distributor = {
      name = "distributor"
      count = 3
    },
    Ingester = {
      name = "ingester"
      count = 3
    }, 
    Querier = {
      name = "querier"
      count = 3
    },
    StoreGateway = {
      name = "store-gateway"
      count = 3
    }, 
    Compactor = {
      name = "compactor"
      count = 3
    },
    AlertManager = {
      name = "alertmanager"
      count = 3
    },
    Ruler = {
      name = "ruler"
      count = 3
    },
    Purger = {
      name = "purger"
      count = 1
    }
  })
}