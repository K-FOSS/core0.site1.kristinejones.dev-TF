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
  LOKI_TARGETS = tomap({
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
    IndexGateway = {
      name = "index-gateway"
      count = 3
    }, 
    Compactor = {
      name = "compactor"
      count = 3
    },
    QueryFrontend = {
      name = "query-frontend"
      count = 3
    },
    QueryScheduler = {
      name = "query-scheduler"
      count = 3
    }
  })
}