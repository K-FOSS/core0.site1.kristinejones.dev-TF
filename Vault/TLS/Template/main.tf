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

locals {
  ONE_HOUR = 60 * 60

  SIX_HOURS = (60 * 60) * 6

  TWELVE_HOURS = (60 * 60) * 12

  ONE_DAY = (60 * 60) * 24

  ONE_WEEK = ((60 * 60) * 24) * 7

  ONE_MONTH = ((60 * 60) * 24) * 31

  THREE_MONTHS = (((60 * 60) * 24) * 31) * 3

  SIX_MONTHS = (((60 * 60) * 24) * 31) * 6

  ONE_YEAR = ((60 * 60) * 24) * 365

  TWO_YEARS = (((60 * 60) * 24) * 365) * 2

  THREE_YEARS = (((60 * 60) * 24) * 365) * 3
}

resource "random_string" "RootMount" {
  length           = 10

  special = false
  upper = false
}

resource "vault_mount" "RootPKI" {
  path        = random_string.RootMount.result

  #
  #
  #
  type        = "pki"

  description = "PKI for the ROOT CA"
  default_lease_ttl_seconds = local.SIX_MONTHS
  max_lease_ttl_seconds = local.THREE_YEARS
}

resource "vault_pki_secret_backend_root_cert" "RootCA" {
  depends_on = [
    vault_mount.RootPKI 
  ]

  backend = vault_mount.RootPKI.path

  type = "internal"

  common_name = "Root CA"
  ttl = local.THREE_YEARS

  #
  # Formats
  #  
  
  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#format-2
  # 
  format = "pem"

  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#private_key_format-2
  #
  private_key_format = "der"

  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#key_type-2
  #
  key_type = "ec"

  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#key_bits-2
  #
  key_bits = 384
}

resource "random_string" "Mount" {
  length           = 10

  special = false
  upper = true
}

resource "vault_mount" "PKI" {
  path        = random_string.Mount.result

  type        = "pki"
  description = "PKI for the Int CA"

  #
  # 
  #
  default_lease_ttl_seconds = local.ONE_YEAR
  max_lease_ttl_seconds = local.THREE_YEARS
}

resource "vault_pki_secret_backend_intermediate_cert_request" "IntermediateCSR" {
  depends_on = [
    vault_mount.RootPKI, vault_mount.PKI
  ]

  backend = vault_mount.PKI.path

  type = "internal"
  common_name = "pki-ca-int"

  #
  # Formats
  #  
  
  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#format-2
  # 
  format = "pem"

  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#private_key_format-2
  #
  private_key_format = "der"
  
  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#key_type-2
  #
  key_type = "ec"
  
  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#key_bits-2
  #
  key_bits = "384"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "IntermediateCSRRootSign" {
  depends_on = [
    vault_pki_secret_backend_intermediate_cert_request.IntermediateCSR 
  ]

  backend = vault_mount.RootPKI.path

  csr = vault_pki_secret_backend_intermediate_cert_request.IntermediateCSR.csr

  common_name = "pki-ca-int"

  exclude_cn_from_sans = true

  organization = "kristianjones.dev"


  #
  # TTL
  #  
  ttl = local.TWO_YEARS
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" { 
  backend = vault_mount.PKI.path 
  
  certificate = "${vault_pki_secret_backend_root_sign_intermediate.IntermediateCSRRootSign.certificate}\n${vault_pki_secret_backend_root_cert.RootCA.certificate}"
}

resource "random_string" "RoleName" {
  length           = 10

  special = false
  upper = true
}

resource "vault_pki_secret_backend_role" "PKIRole" {
  backend = vault_mount.PKI.path

  name    = random_string.RoleName.result

  #
  # Options
  #
  generate_lease = true
  allow_any_name = true

  #
  # TTL
  #
  ttl = local.ONE_YEAR
  max_ttl = local.ONE_YEAR

  #
  # Vault Options: https://www.vaultproject.io/api/secret/pki#key_usage
  # Spec Options: https://pkg.go.dev/crypto/x509#KeyUsage
  # Authenik Orig: https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/certificate_key_pair#example-usage
  #
  key_usage = ["KeyEncipherment", "DigitalSignature"]

  #
  # Vault Options: https://www.vaultproject.io/api/secret/pki#ext_key_usage
  # Spec Options: https://pkg.go.dev/crypto/x509#ExtKeyUsage
  # Authenik Orig: https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/certificate_key_pair#example-usage
  ##
  ext_key_usage = ["ServerAuth"]
}