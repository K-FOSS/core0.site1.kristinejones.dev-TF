output "TLS" {
  value = {
    Mount = vault_mount.PKI

    Role = vault_pki_secret_backend_role.PKIRole
  }
}