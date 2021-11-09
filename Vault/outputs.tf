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
    Hostname = "172.31.241.2"
    Port = 36009

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
# Netbox
#
output "Netbox" {
  value = {
    Token = data.vault_generic_secret.Netbox.data["TOKEN"]
  }
}

#
# NextCloud
#
output "NextCloud" {
  value = {
    Username = data.vault_generic_secret.NextCloud.data["USERNAME"]
    Token = data.vault_generic_secret.NextCloud.data["TOKEN"]
  }
}

#
# GitHub
#
output "GitHub" {
  value = {
    Token = data.vault_generic_secret.GitHub.data["Token"]
  }
}

#
# MikroTik
#
output "MikroTik" {
  value = {
    Home1 = {
      IPAddress = data.vault_generic_secret.Home1MikroTik.data["IPAddress"]
      Username = data.vault_generic_secret.Home1MikroTik.data["Username"]
      Password = data.vault_generic_secret.Home1MikroTik.data["Password"]
    }
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

    Registry = {
      Cert = vault_pki_secret_backend_cert.TinkRegistryCert.certificate
      Key = vault_pki_secret_backend_cert.TinkRegistryCert.private_key
    }
  }
}

output "PomeriumTLS" {
  value = {
    CA = vault_pki_secret_backend_cert.PomeriumProxyCert.ca_chain

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

    Redis = {
      Cert = vault_pki_secret_backend_cert.PomeriumRedisCert.certificate
      Key = vault_pki_secret_backend_cert.PomeriumRedisCert.private_key
    }
  }
}

#
# eJabberD
#
output "eJabberD" {
  value = {


    TLS = {
      CA = vault_pki_secret_backend_cert.eJabberDServerCert.ca_chain

      Server = {
        Cert = vault_pki_secret_backend_cert.eJabberDMQTTServerCert.certificate
        Key = vault_pki_secret_backend_cert.eJabberDMQTTServerCert.private_key
      }

      MQTT = {
        Cert = vault_pki_secret_backend_cert.eJabberDMQTTServerCert.certificate
        Key = vault_pki_secret_backend_cert.eJabberDMQTTServerCert.private_key
      }

      Redis = {
        Cert = vault_pki_secret_backend_cert.eJabberDRedisCert.certificate
        Key = vault_pki_secret_backend_cert.eJabberDRedisCert.private_key
      }
    }

    OpenID = {
      ClientID = data.vault_generic_secret.eJabberDOID.data["ClientID"]
      ClientSecret = data.vault_generic_secret.eJabberDOID.data["ClientSecret"]
    }
  }
}

#
# HomeAssistant
#
output "HomeAssistant" {
  value = {
    MQTT = {
      Connection = {
        Hostname = "ejabberd-mqtt-cont.service.kjdev"
        Port = 1883

        CA = vault_pki_secret_backend_cert.eJabberDServerCert.ca_chain
      }

      Credentials = {
        Username = data.vault_generic_secret.HomeAssistant.data["MQTTUsername"]
        Password = data.vault_generic_secret.HomeAssistant.data["MQTTPassword"]
      }
    }

    Secrets = {
      HomeLocation = {
        HomeLatitude = data.vault_generic_secret.HomeAssistant.data["HomeLatitude"]
        HomeLongitude = data.vault_generic_secret.HomeAssistant.data["HomeLongitude"]
      }
    }


    TLS = {
      CA = vault_pki_secret_backend_cert.HomeAssistantHTTPSCert.ca_chain

      Server = {
        Cert = vault_pki_secret_backend_cert.HomeAssistantHTTPSCert.certificate
        Key = vault_pki_secret_backend_cert.HomeAssistantHTTPSCert.private_key
      }
    }

    OpenID = {
      ClientID = data.vault_generic_secret.eJabberDOID.data["ClientID"]
      ClientSecret = data.vault_generic_secret.eJabberDOID.data["ClientSecret"]
    }
  }
}

#
# Grafana
#

output "Grafana" {
  value = {
    TLS = {
      CA = vault_pki_secret_backend_cert.GrafanaCert.ca_chain
  
      Cert = vault_pki_secret_backend_cert.GrafanaCert.certificate
      Key = vault_pki_secret_backend_cert.GrafanaCert.private_key
    }
  } 
}

#
# Hashicorp Vault 
#

#
# CoreVault
#
output "CoreVault" {
  value = {
    Prometheus = {
      Token = data.vault_generic_secret.CoreVault.data["Token"]
    }
  } 
}

output "Vault" {
  value = {
    Prometheus = {
      Token = data.vault_generic_secret.CoreVault.data["Token"]
    }
  } 
}

#
# Docker Hub
#
output "DockerHub" {
  value = {
    Username = data.vault_generic_secret.DockerHub.data["USERNAME"]
    Token = data.vault_generic_secret.DockerHub.data["TOKEN"]
  } 
}

#
# Development
#

output "GitLab" {
  value = {
    WebServices = {
      
    }
  }
}

#
# Registry
#

output "Registry" {
  value = {
    Harbor = {
      TLS = {
        CA = vault_pki_secret_backend_cert.HarborCoreServerCert.ca_chain

        Core = {
          Cert = vault_pki_secret_backend_cert.HarborCoreServerCert.certificate
          Key = vault_pki_secret_backend_cert.HarborCoreServerCert.private_key
        }

        JobService = {
          Cert = vault_pki_secret_backend_cert.HarborJobServiceServerCert.certificate
          Key = vault_pki_secret_backend_cert.HarborJobServiceServerCert.private_key
        }

        Portal = {
          Cert = vault_pki_secret_backend_cert.HarborPortalServerCert.certificate
          Key = vault_pki_secret_backend_cert.HarborPortalServerCert.private_key
        }

        Registry = {
          Cert = vault_pki_secret_backend_cert.HarborRegistryServerCert.certificate
          Key = vault_pki_secret_backend_cert.HarborRegistryServerCert.private_key
        }

      }
    }
  }
}