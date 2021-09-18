output "TFMount" {
  value = vault_mount.Terraform
}

output "BitwardenDB" {
  value = data.vault_generic_secret.Bitwarden
}