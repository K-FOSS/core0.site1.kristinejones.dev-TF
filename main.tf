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

#
# Hashicorp Vault
#

module "Vault" {
  source = "./Vault"
}

#
# Hashicorp Consul
#

module "Consul" {
  source = "./Consul"

  Patroni = {
    Prefix = "patroninew"
    ServiceName = "patroninew"
  }
}


#
# Databases
#

module "GrafanaDatabase" {
  source = "./Database"

  Credentials = module.Vault.Database
}



#
# Hashicorp Nomad
#

module "Nomad" {
  source = "./Nomad"


  #
  # Bitwarden
  #

  Bitwarden = {
    Database = {
      Hostname = "master.patroninew.service.kjdev"

      Username = module.Vault.BitwardenDB.data["username"]
      Password = module.Vault.BitwardenDB.data["password"]

      Database = "bitwarden"
    }
  }

  #
  # Caddy Web Ingress
  #

  Ingress = {
    Cloudflare = {
      Token = module.Vault.Cloudflare.data["Token"]
    }

    Consul = {
      Token = module.Vault.Caddy.data["CONSUL_HTTP_TOKEN"]
      EncryptionKey = module.Vault.Caddy.data["CADDY_CLUSTERING_CONSUL_AESKEY"]
    }
  }

  #
  # Grafana
  #

  Grafana = {
    Database = {
      Hostname = "master.site0core1psql.service.kjdev"

      Username = module.Vault.BitwardenDB.data["username"]
      Password = module.Vault.BitwardenDB.data["password"]

      Database = "bitwarden"
    }
  }

  #
  # Patroni
  #
  Patroni = {
    Consul = module.Consul.Patroni
  }
}