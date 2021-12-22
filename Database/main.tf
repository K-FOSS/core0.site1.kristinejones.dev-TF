terraform {
  required_providers {
    #
    # PostgreSQL
    #
    # Docs: https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs
    #
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.14.0"
    }


    #
    # Randomness
    #
    # TODO: Find a way to best improve true randomness?
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/random/latest/docs
    #
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

locals {
  Hostname = var.Credentials.Hostname
  Port = var.Credentials.Port
}

#
# TODO: Move to Vault mTLS
#
provider "postgresql" {
  #
  # Connection Specs
  #
  host            = local.Hostname
  port            = local.Port
  sslmode         = "disable"

  #
  # Authenication
  #
  username        = var.Credentials.Username
  password        = var.Credentials.Password

  connect_timeout = 15
}

#
# Database Name
#
resource "random_string" "Name" {
  length = 10
  special = false
}

resource "random_password" "RolePassword" {
  length = 20
  special = false
}

resource "postgresql_role" "User" {
  name = random_string.Name.result

  login = true
  password = random_password.RolePassword.result
}

resource "postgresql_database" "Database" {
  name = random_string.Name.result

  owner = postgresql_role.User.name
}