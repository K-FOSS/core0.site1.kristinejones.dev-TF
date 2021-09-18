terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "2.22.1"
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