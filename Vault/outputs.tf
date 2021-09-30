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

#
# Database
#

output "Database" {
  value = {
    Hostname = "master.patroninew.service.kjdev"
    Port = 5432

    Username = data.vault_generic_secret.Database.data["USERNAME"]
    Password = data.vault_generic_secret.Database.data["PASSWORD"]
  }
}

output "Pomerium" {
  value = {
    ClientID = data.vault_generic_secret.PomeriumOID.data["ClientID"]
    ClientSecret = data.vault_generic_secret.PomeriumOID.data["ClientSecret"]
  }
}

#
# Minio
#

output "Minio" {
  value = {
    AccessKey = data.vault_generic_secret.Minio.data["AccessKey"]
    SecretKey = data.vault_generic_secret.Minio.data["SecretKey"]
  }
}

#
# TrueNAS NAS
#
output "NAS" {
  value = {
    Password = data.vault_generic_secret.NASAuth.data["PASSWORD"]
  }
}

#
# Tinkerbell
#
output "Tinkerbell" {
  value = {
    CA = vault_pki_secret_backend_cert.TinkCert.issuing_ca

    Tink = {
      Cert = vault_pki_secret_backend_cert.TinkCert.certificate
      Key = vault_pki_secret_backend_cert.TinkCert.private_key
    }

    Hegel = {
      Cert = vault_pki_secret_backend_cert.HegelCert.certificate
      Key = vault_pki_secret_backend_cert.HegelCert.private_key
    }

  }
}

output "PomeriumTLS" {
  value = {
    CA = vault_pki_secret_backend_cert.PomeriumCert.issuing_ca

    Proxy = {
      Cert = vault_pki_secret_backend_cert.PomeriumProxyCert.certificate
      Key = vault_pki_secret_backend_cert.PomeriumProxyCert.private_key
    }

    DataBroker = {
      Cert = vault_pki_secret_backend_cert.PomeriumDataBrokerCert.certificate
      Key = vault_pki_secret_backend_cert.PomeriumDataBrokerCert.private_key
    }

    Authenticate = {
      Cert = vault_pki_secret_backend_cert.PomeriumAuthenticateCert.certificate
      Key = vault_pki_secret_backend_cert.PomeriumAuthenticateCert.private_key
    }

    Authorize = {
      Cert = vault_pki_secret_backend_cert.PomeriumAuthorizeCert.certificate
      Key = vault_pki_secret_backend_cert.PomeriumAuthorizeCert.private_key
    }
  }
}