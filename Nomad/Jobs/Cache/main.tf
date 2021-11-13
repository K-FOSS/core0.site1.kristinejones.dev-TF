terraform {
  required_providers {
    #
    # Hashicorp Vault
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    #
    nomad = {
      source = "hashicorp/nomad"
      version = "1.4.15"
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


resource "nomad_job" "CacheWebJobFile" {
  jobspec = templatefile("${path.module}/Jobs/CacheWeb.hcl", {
    Caddyfile = templatefile("${path.module}/Configs/Caddyfile.json", {

    })
  })
}

resource "nomad_job" "GitHubCacheJobFile" {
  jobspec = templatefile("${path.module}/Jobs/GitHubCache.hcl", {

  })
}

#
# NextCloud
#

resource "nomad_job" "NextCloudCacheJobFile" {
  jobspec = templatefile("${path.module}/Jobs/NextCloud.hcl", {

  })
}

#
# OpenProject
#

resource "nomad_job" "OpenProjectRedisJobFile" {
  jobspec = templatefile("${path.module}/Jobs/OpenProject.hcl", {

  })
}

#
# Cortex Memcached
#
resource "nomad_job" "CortexCacheJobFile" {
  jobspec = templatefile("${path.module}/Jobs/CortexCache.hcl", {

  })
}

#
# Recursive DNS Cache
#

resource "nomad_job" "DNSCacheJobFile" {
  jobspec = templatefile("${path.module}/Jobs/DNSCache.hcl", {

  })
}

#
# Authentik Cache
#

resource "nomad_job" "AuthentikCacheJobFile" {
  jobspec = templatefile("${path.module}/Jobs/AuthentikRedis.hcl", {
    
  })
}

#
# Pomerium
#

resource "nomad_job" "PomeriumCacheJobFile" {
  jobspec = templatefile("${path.module}/Jobs/PomeriumCache.hcl", var.Pomerium.RedisCache)
}

#
# GitLab
#

resource "nomad_job" "PomeriumCacheJobFile" {
  jobspec = templatefile("${path.module}/Jobs/Gitlab.hcl", {

  })
}