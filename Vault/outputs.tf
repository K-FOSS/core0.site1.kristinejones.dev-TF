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
# variable "Tinkerbell" {
#   value = {
#     CA = ""
#     Cert = ""
#     Key = ""
#   }
# }