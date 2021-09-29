terraform {
  required_providers {
    #
    # Hashicorp Vault
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    #
    vault = {
      source = "hashicorp/vault"
      version = "2.24.0"
    }
  }
}

#
# Generic Secrets
#
resource "vault_mount" "Terraform" {
  path        = "CORE0_SITE1"

  type        = "kv-v2"

  description = "Terraform Consul Sync Core Secrets"
}

resource "vault_generic_secret" "TerraformTest" {
  path = "${vault_mount.Terraform.path}/TMP_TEST"

  data_json = jsonencode({
    testing = "HelloWorld"
    helloworld = "Testing123"
  })
}

#
# Cloudflare
# 
data "vault_generic_secret" "Cloudflare" {
  path = "${vault_mount.Terraform.path}/Cloudflare"
}

#
# Caddy
#
data "vault_generic_secret" "Caddy" {
  path = "${vault_mount.Terraform.path}/Caddy"
}

#
# Database
#
data "vault_generic_secret" "Database" {
  path = "${vault_mount.Terraform.path}/Database"
}


#
# Bitwarden
#

data "vault_generic_secret" "Bitwarden" {
  path = "keycloak/BitwardenDB"
}

#
# Pomerium
#
# TODO: Move this to Consul KV triggered Terraform Deployment
# 

data "vault_generic_secret" "PomeriumOID" {
  path = "${var.Pomerium.VaultPath}"
}

#
# PostgreSQL
#

#
# Minio
#

data "vault_generic_secret" "Minio" {
  path = "${vault_mount.Terraform.path}/Minio"
}

#
# TrueNAS NAS
#
data "vault_generic_secret" "NASAuth" {
  path = "keycloak/NASAuth"
}

#
# Tinker Bell TLS
# 
module "TinkerbellPKI" {
  source = "./TLS/Template"
}

resource "vault_pki_secret_backend_cert" "TinkCert" {
  backend = module.TinkerbellPKI.TLS.Mount.path
  name = module.TinkerbellPKI.TLS.Role.name

  common_name = "tinkerbell"

  alt_names = ["tink-grpc-cont.service.kjdev", "tink-http-cont.service.kjdev"]
}

#
# Pomerium
#
module "Pomerium" {
  source = "./TLS/Template"
}

# resource "vault_pki_secret_backend_cert" "PomeriumCert" {
#   backend = module.Pomerium.TLS.Mount.path
#   name = module.Pomerium.TLS.Role.name

#   common_name = "pomerium-proxy-cont.service.kjdev"

#   alt_names = [
#     "pomerium-authenticate-cont.service.kjdev", 
#     "pomerium-authorize-cont.service.kjdev", 
#     "pomerium-databroker-cont.service.kjdev", 
#     "pomerium-proxy-cont.service.kjdev"]
# }