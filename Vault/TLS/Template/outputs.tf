output "TLS" {
  value = {
    Role = vault_pki_secret_backend_role.PKIRole
  }
}