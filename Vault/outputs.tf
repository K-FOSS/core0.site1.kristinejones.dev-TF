output "TFMount" {
  value = vault_mount.Terraform
}

#
# Cloudflare
#

output "Cloudflare" {
  value = data.vault_generic_secret.Cloudflare
}

#
# AAA
#

output "AAA" {
  value = {
    Authentik = {
      LDAP = {
        AuthentikHost = data.vault_generic_secret.LDAP.data["AuthentikHost"]
        AuthentikToken = data.vault_generic_secret.LDAP.data["AuthentikToken"]
      }
    }
  }
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
    Hostname = "172.16.20.21"
    Port = 36009

    Username = data.vault_generic_secret.Database.data["USERNAME"]
    Password = data.vault_generic_secret.Database.data["PASSWORD"]
  }
}

#
# Minio
#

output "Minio" {
  value = {
    AccessKey = data.vault_generic_secret.Minio.data["AccessKey"]
    SecretKey = data.vault_generic_secret.Minio.data["SecretKey"]
    
    AccessToken = data.vault_generic_secret.Minio.data["SecretKey"]
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
# iDRAC
#
output "iDRAC" {
  value = {
    Username = data.vault_generic_secret.iDRAC.data["Username"]
    Password = data.vault_generic_secret.iDRAC.data["Password"]
  }
}

#
# SMTP
#

output "SMTP" {
  value = {
    Server = data.vault_generic_secret.SMTP.data["Server"]
    Port = data.vault_generic_secret.SMTP.data["Port"]
    
    Username = data.vault_generic_secret.SMTP.data["Username"]
    Password = data.vault_generic_secret.SMTP.data["Password"]
  }
}

#
# TMP KJDev MSTeams
#
output "MSTeams" {
  value = {
    Webhook = data.vault_generic_secret.MSTeams.data["Webhook"]
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
# ENMS
#

output "ENMS" {
  value = {
    Repo = {
      URI = data.vault_generic_secret.ENMS.data["RepoURI"]
      Token = data.vault_generic_secret.ENMS.data["RepoToken"]
    }
  }
}

#
# OpenProject
#

output "OpenProject" {
  value = {
    OpenID = {
      ClientID = data.vault_generic_secret.OpenProject.data["ClientID"]
      ClientSecret = data.vault_generic_secret.OpenProject.data["ClientSecret"]
    }
  }
}

#
# Business
#

output "Business" {
  value = {
    Vikunja = {
      OpenID = {
        ClientID = data.vault_generic_secret.Vikunja.data["OpenIDClientID"]
        ClientSecret = data.vault_generic_secret.Vikunja.data["OpenIDClientSecret"]
      }
    }

    Outline = {
      OpenID = {
        ClientID = data.vault_generic_secret.Outline.data["OpenIDClientID"]
        ClientSecret = data.vault_generic_secret.Outline.data["OpenIDClientSecret"]
      }
    }
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

output "Pomerium" {
  value = {
    OpenID = {
      ClientID = data.vault_generic_secret.PomeriumOID.data["ClientID"]
      ClientSecret = data.vault_generic_secret.PomeriumOID.data["ClientSecret"]
    }

    Secrets = {
      SigningKey = base64encode(tls_private_key.PomeriumSigningKey.private_key_pem)
    }

    TLS = {
      CA = vault_pki_secret_backend_cert.PomeriumProxyCert.ca_chain

      Redis = {
        CA = vault_pki_secret_backend_cert.PomeriumProxyCert.ca_chain

        Cert = vault_pki_secret_backend_cert.PomeriumRedisCert.certificate
        Key = vault_pki_secret_backend_cert.PomeriumRedisCert.private_key
      }

      Authenticate = {
        Metrics = {
          Server = {
            CA = ""

            Cert = ""
            Key = ""
          }
        }

        Server = {
          CA = vault_pki_secret_backend_cert.PomeriumProxyCert.ca_chain

          Cert = vault_pki_secret_backend_cert.PomeriumAuthenticateCert.certificate
          Key = vault_pki_secret_backend_cert.PomeriumAuthenticateCert.private_key
        }
      }

      Authorize = {
        Metrics = {
          Server = {
            CA = ""
            
            Cert = ""
            Key = ""
          }
        }

        Server = {
          CA = vault_pki_secret_backend_cert.PomeriumProxyCert.ca_chain

          Cert = vault_pki_secret_backend_cert.PomeriumAuthorizeCert.certificate
          Key = vault_pki_secret_backend_cert.PomeriumAuthorizeCert.private_key
        }
      }
      
      DataBroker = {
        Metrics = {
          Server = {
            CA = ""
            
            Cert = ""
            Key = ""
          }
        }

        Server = {
          CA = vault_pki_secret_backend_cert.PomeriumProxyCert.ca_chain
          
          Cert = vault_pki_secret_backend_cert.PomeriumDataBrokerCert.certificate
          Key = vault_pki_secret_backend_cert.PomeriumDataBrokerCert.private_key
        }
      }

      Proxy = {
        Metrics = {
          Server = {
            CA = ""
            
            Cert = ""
            Key = ""
          }
        }

        Server = {
          CA = vault_pki_secret_backend_cert.PomeriumProxyCert.ca_chain
          
          Cert = vault_pki_secret_backend_cert.PomeriumProxyCert.certificate
          Key = vault_pki_secret_backend_cert.PomeriumProxyCert.private_key
        }
      }
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
    AccessToken = data.vault_generic_secret.HASS.data["AccessToken"]

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
# DHCP
#
output "DHCP" {
  value = {
    TLS = {
      CA = vault_pki_secret_backend_cert.DHCPServerCert.ca_chain

      # Server = {
      #   Cert = vault_pki_secret_backend_cert.DHCPServerCert.certificate
      #   Key = vault_pki_secret_backend_cert.DHCPServerCert.private_key
      # }
    }
  }
}

#
# Bitwarden
#

output "Bitwarden" {
  value = {
    Database = {
      Username = data.vault_generic_secret.Bitwarden.data["username"]
      Password = data.vault_generic_secret.Bitwarden.data["password"]
    }

    TLS = {
      CA = vault_pki_secret_backend_cert.BitwardenServerCert.ca_chain

      Server = {
        Cert = vault_pki_secret_backend_cert.BitwardenServerCert.certificate
        Key = vault_pki_secret_backend_cert.BitwardenServerCert.private_key
      }
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
    OpenID = {
      ClientID = data.vault_generic_secret.GitLab.data["OpenIDClient"]
      ClientSecret = data.vault_generic_secret.GitLab.data["OpenIDSecret"]
    }

    Secrets = {
      OpenIDSigningKey = tls_private_key.GitLabOpenIDSigningKey.private_key_pem
    }

    TLS = {
      WebService = {
        CA = vault_pki_secret_backend_cert.GitLabWebServicesCert.ca_chain
  
        Cert = vault_pki_secret_backend_cert.GitLabWebServicesCert.certificate
        Key = vault_pki_secret_backend_cert.GitLabWebServicesCert.private_key
      }

      WorkHorse = {
        CA = vault_pki_secret_backend_cert.GitLabWorkHorseCert.ca_chain
  
        Cert = vault_pki_secret_backend_cert.GitLabWorkHorseCert.certificate
        Key = vault_pki_secret_backend_cert.GitLabWorkHorseCert.private_key
      }

      Registry = {
        CA = vault_pki_secret_backend_cert.HarborCoreServerCert.ca_chain

        Cert = vault_pki_secret_backend_cert.HarborRegistryServerCert.certificate
        Key = vault_pki_secret_backend_cert.HarborRegistryServerCert.private_key
      }
    }
  }
}

#
# Misc
#

output "Misc" {
  value = {
    Ivatar = {
      OpenID = {
        ClientID = data.vault_generic_secret.Ivatar.data["OpenIDClientID"]
        ClientSecret = data.vault_generic_secret.Ivatar.data["OpenIDClientSecret"]
      }
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

        RegistryCTL = {
          Cert = vault_pki_secret_backend_cert.HarborRegistryCTLServerCert.certificate
          Key = vault_pki_secret_backend_cert.HarborRegistryCTLServerCert.private_key
        }

        Exporter = {
          Cert = vault_pki_secret_backend_cert.HarborExporterServerCert.certificate
          Key = vault_pki_secret_backend_cert.HarborExporterServerCert.private_key
        }

      }
    }
  }
}


#
# Prometheus
#

output "Prometheus" {
  value = {
    TLS = {
      Pomerium = {
        Server = {
          CA = ""

          Cert = ""
          Key = ""
        }
      }
    }
  }
}