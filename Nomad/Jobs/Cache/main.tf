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

#######
# AAA #
#######

#
# Authentik Cache
#

resource "nomad_job" "AuthentikCacheJobFile" {
  jobspec = templatefile("${path.module}/Jobs/AuthentikRedis.hcl", {
    
  })
}

#
# Teleport
#
# TODO: Figure out if Teleport still uses ETCD or can use Redis and/or Memcached
#

resource "random_password" "TeleportETCDClusterKey" {
  length = 16
  special = false
}

resource "nomad_job" "TeleportETCDJobFile" {
  jobspec = templatefile("${path.module}/Jobs/TeleportETCD.hcl", {
    Teleport = var.AAA.Teleport

    Secrets = {
      TeleportClusterKey = random_password.TeleportETCDClusterKey.result
    }
  })
}

###########
# Backups #
###########

#
# TODO: Tasks/Cron Queueing
#

#
# TODO: PSQL Backups
#

############
# Business #
############

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
# Outline
#

resource "nomad_job" "OutlineJobFile" {
  jobspec = templatefile("${path.module}/Jobs/Outline.hcl", {

  })
}

#
# Vikunja
#

resource "nomad_job" "VikunjaJobFile" {
  jobspec = templatefile("${path.module}/Jobs/VikunjaRedis.hcl", {

  })
}

#
# Zammad
#

resource "nomad_job" "ZammadJobFile" {
  jobspec = templatefile("${path.module}/Jobs/ZammadCache.hcl", {

  })
}





#########
# Cache #
#########


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




##################
# Communications #
##################

#
# TODO: Mattermost
#

#
# TODO: Matrix
#

############
# Database #
############

#
# TODO: PGBouncer
#

#
# TODO: PGAdmin
#

#
# TODO: Get MongoDB Postgresql interface online
#

#
# TODO: Smart AI based PSQL caching proxy, ideally with Consul based gossip and routing of end DB traffic
#




###############
# Development #
###############

#
# GitLab
#

resource "nomad_job" "GitLabJobFile" {
  jobspec = templatefile("${path.module}/Jobs/GitLab.hcl", {

  })
}





########
# Draw #
########

#
# DrawIO
#

resource "nomad_job" "DrawIOJobFile" {
  jobspec = templatefile("${path.module}/Jobs/DrawIO.hcl", {

  })
}

############
# eJabberD #
############

resource "nomad_job" "eJabberDJobFile" {
  jobspec = templatefile("${path.module}/Jobs/eJabberD.hcl", {
    Redis = var.eJabberD.Redis
  })
}

###########
# Grafana #
###########

#
# TODO: Move Grafana Redis & Memcached here
#

########
# Home #
########

#
# TODO: HomeAssistant MQTT Cache, and Stuff
#




###########
# Ingress #
###########

#
# TODO: Ingress Cache
#



#############
# Inventory #
#############

#
# MeshCentral
#

#
# Netbox
#



########
# Logs #
########


#
# Grafana Loki
#

module "LokiMemcache" {
  source = "./Templates/Memcached"

  Service = {
    Name = "Loki"

    Consul = {
      ServiceName = "loki"
    }
  }
}



##################
# Machine Static #
##################

#
# TODO: S3, TFTP, FTP, SCP, SFTP Proxies/Cache/CDN Network
#






###########
# Metrics #
###########


##########
# Cortex #
##########

module "CortexMemcache" {
  source = "./Templates/Memcached"

  Service = {
    Name = "Cortex"

    Consul = {
      ServiceName = "cortex"
    }
  }
}



########
# Misc #
########

#
# TODO: ShareX Compat Server with OpenID SSO/Auth, LDAP Sync, and S3 Storage, with NextCloud & PhotoPrism Integration
#


###########
# Network #
###########





###########
# Tracing #
###########

#
# Tempo
#

module "TempoMemcache" {
  source = "./Templates/Memcached"

  Service = {
    Name = "Tempo"

    Consul = {
      ServiceName = "tempo"
    }
  }
}

###########
# Network #
###########

#
# DNS
#


#
# Recursive DNS Cache
#

# resource "nomad_job" "DNSCacheJobFile" {
#   jobspec = templatefile("${path.module}/Jobs/DNSCache.hcl", {

#   })
# }



#
# Pomerium
#

resource "nomad_job" "PomeriumCacheJobFile" {
  jobspec = templatefile("${path.module}/Jobs/PomeriumCache.hcl", var.Pomerium.RedisCache)
}

#
# Registry
#

resource "nomad_job" "RegistryRedisJobFile" {
  jobspec = templatefile("${path.module}/Jobs/RegistryRedis.hcl", {

  })
}

#
# Security
#

resource "nomad_job" "RegistryRedisJobFile" {
  jobspec = templatefile("${path.module}/Jobs/ThreatMapperRedis.hcl", {

  })
}