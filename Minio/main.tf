terraform {
  required_providers {
    #
    # Minio Provider
    #
    # Docs: https://registry.terraform.io/providers/refaktory/minio/latest/docs
    #
    minio = {
      source = "refaktory/minio"
      version = "0.1.0"
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
  Hostname = var.Connection.Hostname
  Port = var.Connection.Port
  Endpoint = "${var.Connection.Hostname}:${var.Connection.Port}"
}

provider "minio" {
  # The Minio server endpoint.
  # NOTE: do NOT add an http:// or https:// prefix!
  # Set the `ssl = true/false` setting instead.
  endpoint = local.Endpoint
  # Specify your minio user access key here.
  access_key = "${var.Credentials.AccessKey}"
  # Specify your minio user secret key here.
  secret_key = "${var.Credentials.SecretKey}"
  # If true, the server will be contacted via https://
  ssl = false
}

resource "random_string" "Name" {
  length           = 6

  special = false
  upper = false
}

resource "random_uuid" "BucketName" {
}

resource "minio_bucket" "Bucket" {
  name = "${random_uuid.BucketName.result}-${random_string.Name.result}"
}

#
# Minio Policy
#

resource "minio_canned_policy" "BucketPolicy" {
  name = "${random_string.Name.result}ACL"
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${minio_bucket.Bucket.name}/*"
      ]
    }
  ]
}
EOT
}


#
# Minio User
#

resource "random_password" "UserPassword" {
  length           = 16
  special          = true
}

resource "minio_user" "BucketUser" {
  access_key = random_string.Name.result
  secret_key = random_password.UserPassword.result

  policies = [
    minio_canned_policy.BucketPolicy.name
  ]
}

