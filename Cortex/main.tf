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
      count = 2

      resources = {
        cpu = 100
        memory = 512
        memory_max = 1000
      }
    },
    Ingester = {
      name = "ingester"
      count = 3

      resources = {
        cpu = 100
        memory = 512
        memory_max = 1000
      }
    }, 
    Querier = {
      name = "querier"
      count = 2

      resources = {
        cpu = 50
        memory = 128
        memory_max = 1000
      }
    },
    StoreGateway = {
      name = "store-gateway"
      count = 2

      resources = {
        cpu = 100
        memory = 512
        memory_max = 1000
      }
    }, 
    Compactor = {
      name = "compactor"
      count = 1

      resources = {
        cpu = 256
        memory = 256
        memory_max = 256
      }
    },
    QueryFrontend = {
      name = "query-frontend"
      count = 2

      resources = {
        cpu = 10
        memory = 32
        memory_max = 256
      }
    },
    AlertManager = {
      name = "alertmanager"
      count = 1

      resources = {
        cpu = 32
        memory = 64
        memory_max = 64
      }
    },
    Ruler = {
      name = "ruler"
      count = 1

      resources = {
        cpu = 10
        memory = 32
        memory_max = 256
      }
    },
    QueryScheduler = {
      name = "query-scheduler"
      count = 3
  
      resources = {
        cpu = 64
        memory = 96
        memory_max = 512
      }
    }, 
    Purger = {
      name = "purger"
      count = 1

      resources = {
        cpu = 10
        memory = 32
        memory_max = 128
      }
    },
    Configs = {
      name = "configs"
      count = 1

      resources = {
        cpu = 128
        memory = 64
        memory_max = 64
      }
    }
  })
}