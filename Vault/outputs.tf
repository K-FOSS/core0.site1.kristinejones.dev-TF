output "TFMount" {
  value = vault_mount.Terraform
}

#
# Bitwarden
#

output "BitwardenDB" {
  value = data.vault_generic_secret.Bitwarden
}

#
# Cloudflare
#

output "Cloudflare" {
  value = data.vault_generic_secret.Cloudflare
}

#
# Caddy
#

output "Caddy" {
  value = data.vault_generic_secret.Caddy
}