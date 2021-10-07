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

      resources = {
        cpu = 100
        memory = 200
      }
    },
    Ingester = {
      name = "ingester"
      count = 3

      resources = {
        cpu = 100
        memory = 200
      }
    }, 
    Querier = {
      name = "querier"
      count = 3

      resources = {
        cpu = 100
        memory = 200
      }
    },
    StoreGateway = {
      name = "store-gateway"
      count = 3

      resources = {
        cpu = 100
        memory = 200
      }
    }, 
    Compactor = {
      name = "compactor"
      count = 1

      resources = {
        cpu = 100
        memory = 200
      }
    },
    QueryFrontend = {
      name = "query-frontend"
      count = 3

      resources = {
        cpu = 100
        memory = 200
      }
    },
    AlertManager = {
      name = "alertmanager"
      count = 3

      resources = {
        cpu = 100
        memory = 200
      }
    },
    Ruler = {
      name = "ruler"
      count = 3

      resources = {
        cpu = 100
        memory = 200
      }
    },
    QueryScheduler = {
      name = "query-scheduler"
      count = 3
  
      resources = {
        cpu = 100
        memory = 200
      }
    }, 
    Purger = {
      name = "purger"
      count = 1

      resources = {
        cpu = 100
        memory = 200
      }
    }
  })
}