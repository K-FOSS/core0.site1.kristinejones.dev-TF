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

module "Vault" {
  source = "./Vault"
}

module "Nomad" {
  source = "./Nomad"

  Bitwarden = {
    Database = {
      Hostname = "master.site0core1psql.service.kjdev"

      Username = module.Vault.BitwardenDB.data["username"]
      Password = module.Vault.BitwardenDB.data["password"]

      Database = "bitwarden"
    }
  }

  Ingress = {
    Cloudflare = {
      Token = module.Vault.Cloudflare.data["Token"]
    }

    Consul = {
      Token = module.Vault.Caddy.data["CONSUL_HTTP_TOKEN"]
      EncryptionKey = module.Vault.Caddy.data["CADDY_CLUSTERING_CONSUL_AESKEY"]
    }
  }

}