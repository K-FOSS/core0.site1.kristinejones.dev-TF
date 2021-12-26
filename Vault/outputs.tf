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

    Teleport = {
      OpenID = {
        ClientID = data.vault_generic_secret.Teleport.data["OpenIDClient"]
        ClientSecret = data.vault_generic_secret.Teleport.data["OpenIDClientSecret"]
      }

      TLS = {
        CA = vault_pki_secret_backend_cert.TeleportProxyCert.ca_chain

        ETCD = {
          CA = vault_pki_secret_backend_cert.TeleportETCDCert.ca_chain

          Cert = vault_pki_secret_backend_cert.TeleportETCDCert.certificate
          Key = vault_pki_secret_backend_cert.TeleportETCDCert.private_key
        }

        Proxy = {
          CA = vault_pki_secret_backend_cert.TeleportProxyCert.ca_chain

          Cert = vault_pki_secret_backend_cert.TeleportProxyCert.certificate
          Key = vault_pki_secret_backend_cert.TeleportProxyCert.private_key
        }

        Auth = {
          CA = vault_pki_secret_backend_cert.TeleportAuthCert.ca_chain

          Cert = vault_pki_secret_backend_cert.TeleportAuthCert.certificate
          Key = vault_pki_secret_backend_cert.TeleportAuthCert.private_key
        }

        Tunnel = {
          CA = vault_pki_secret_backend_cert.TeleportTunnelCert.ca_chain

          Cert = vault_pki_secret_backend_cert.TeleportTunnelCert.certificate
          Key = vault_pki_secret_backend_cert.TeleportTunnelCert.private_key
        }

        Kube = {
          CA = vault_pki_secret_backend_cert.TeleportKubeCert.ca_chain

          Cert = vault_pki_secret_backend_cert.TeleportKubeCert.certificate
          Key = vault_pki_secret_backend_cert.TeleportKubeCert.private_key
        }
      }
    }
  }
}

#
# Communications
#

output "Communications" {
  value = {
    Mattermost = {
      GitLab = {
        ClientID = data.vault_generic_secret.Mattermost.data["GitLabClientID"]
        ClientSecret = data.vault_generic_secret.Mattermost.data["GitLabClientSecret"]
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
    Hostname = "172.31.241.66"
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
    
    AccessToken = data.vault_generic_secret.Minio.data["AccessToken"]
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
# Servers
#

output "Servers" {
  value = {
    Rancher = {
      OpenID = {
        ClientID = data.vault_generic_secret.Rancher.data["OpenIDClientID"]
        ClientSecret = data.vault_generic_secret.Rancher.data["OpenIDClientSecret"]
      }

      LDAP = {
        Username = data.vault_generic_secret.Rancher.data["LDAPUsername"]
        Password = data.vault_generic_secret.Rancher.data["LDAPPassword"]
      }
    }

    HashUI = {
      OpenID = {
        ClientID = data.vault_generic_secret.HashUI.data["OpenIDClientID"]
        ClientSecret = data.vault_generic_secret.HashUI.data["OpenIDClientSecret"]
      }

      LDAP = {
        Username = data.vault_generic_secret.HashUI.data["LDAPUsername"]
        Password = data.vault_generic_secret.HashUI.data["LDAPPassword"]
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
      ClientID = data.vault_generic_secret.eJabberD.data["OpenIDClientID"]
      ClientSecret = data.vault_generic_secret.eJabberD.data["OpenIDClientSecret"]
    }

    LDAP = {
      Username = data.vault_generic_secret.eJabberD.data["LDAPUsername"]
      Password = data.vault_generic_secret.eJabberD.data["LDAPPassword"]
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

    LDAP = {
      Username = data.vault_generic_secret.BitwardenCore.data["LDAPUsername"]
      Password = data.vault_generic_secret.BitwardenCore.data["LDAPPassword"]
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

    LDAP = {
      Username = data.vault_generic_secret.GitLab.data["LDAPUsername"]
      Password = data.vault_generic_secret.GitLab.data["LDAPPassword"]
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

        Cert = vault_pki_secret_backend_cert.HarborGitLabRegistryServerCert.certificate
        Key = vault_pki_secret_backend_cert.HarborGitLabRegistryServerCert.private_key
      }
    }
  }
}

#
# Education
#

output "Education" {
  value = {
    Moodle = {
      OpenID = {
        ClientID = ""
        ClientSecret = ""
      }

      TLS = {
        CA = vault_pki_secret_backend_cert.MoodleCoreServer.ca_chain

        CoreServer = {
          CA = vault_pki_secret_backend_cert.MoodleCoreServer.ca_chain
    
          Cert = vault_pki_secret_backend_cert.MoodleCoreServer.certificate
          Key = vault_pki_secret_backend_cert.MoodleCoreServer.private_key
        }
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

        GitLabRegistry = {
          Cert = vault_pki_secret_backend_cert.HarborGitLabRegistryServerCert.certificate
          Key = vault_pki_secret_backend_cert.HarborGitLabRegistryServerCert.private_key
        } 

        GitLabRegistryCTL = {
          Cert = vault_pki_secret_backend_cert.HarborGitLabRegistryCTLServerCert.certificate
          Key = vault_pki_secret_backend_cert.HarborGitLabRegistryCTLServerCert.private_key
        }

        RegistryCTL = {
          Cert = vault_pki_secret_backend_cert.HarborRegistryCTLServerCert.certificate
          Key = vault_pki_secret_backend_cert.HarborRegistryCTLServerCert.private_key
        }

        Exporter = {
          Cert = vault_pki_secret_backend_cert.HarborExporterServerCert.certificate
          Key = vault_pki_secret_backend_cert.HarborExporterServerCert.private_key
        }

        ChartMuseum = {
          CA = vault_pki_secret_backend_cert.HarborChartMuseumServerCert.ca_chain
          Cert = vault_pki_secret_backend_cert.HarborChartMuseumServerCert.certificate
          Key = vault_pki_secret_backend_cert.HarborChartMuseumServerCert.private_key
        }

      }
    }
  }
}

#
# Search
#
output "Search" {
  value = {
    OpenSearch = {
      OpenID = {
        ClientID = ""
        ClientSecret = ""
      }

      TLS = {
        CA = vault_pki_secret_backend_cert.OpenSearchCoordinator0Cert.ca_chain

        Coordinator = {
          Coordinator0 = {
            CA = vault_pki_secret_backend_cert.OpenSearchCoordinator0Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchCoordinator0Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchCoordinator0Cert.private_key
          }

          Coordinator1 = {
            CA = vault_pki_secret_backend_cert.OpenSearchCoordinator1Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchCoordinator1Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchCoordinator1Cert.private_key
            
          }
    
          Coordinator2 = {
            CA = vault_pki_secret_backend_cert.OpenSearchCoordinator2Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchCoordinator2Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchCoordinator2Cert.private_key
            
          }
        }

        Ingest = {
          Ingest0 = {
            CA = vault_pki_secret_backend_cert.OpenSearchIngest0Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchIngest0Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchIngest0Cert.private_key

          }

          Ingest1 = {
            CA = vault_pki_secret_backend_cert.OpenSearchIngest1Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchIngest1Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchIngest1Cert.private_key

          }

          Ingest2 = {
            CA = vault_pki_secret_backend_cert.OpenSearchIngest2Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchIngest2Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchIngest2Cert.private_key

          }
        }

        Master = {
          Master0 = {
            CA = vault_pki_secret_backend_cert.OpenSearchMain0Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchMain0Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchMain0Cert.private_key

          }

          Master1 = {
            CA = vault_pki_secret_backend_cert.OpenSearchMain1Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchMain1Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchMain1Cert.private_key

          }

          Master2 = {
            CA = vault_pki_secret_backend_cert.OpenSearchMain2Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchMain2Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchMain2Cert.private_key

          }
        }

        Data = {
          Data0 = {
            CA = vault_pki_secret_backend_cert.OpenSearchData0Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchData0Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchData0Cert.private_key

          }

          Data1 = {
            CA = vault_pki_secret_backend_cert.OpenSearchData1Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchData1Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchData1Cert.private_key

          }

          Data2 = {
            CA = vault_pki_secret_backend_cert.OpenSearchData2Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchData2Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchData2Cert.private_key

          }

          Data3 = {
            CA = vault_pki_secret_backend_cert.OpenSearchData3Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchData3Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchData3Cert.private_key

          }

          Data4 = {
            CA = vault_pki_secret_backend_cert.OpenSearchData4Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchData4Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchData4Cert.private_key

          }

          Data5 = {
            CA = vault_pki_secret_backend_cert.OpenSearchData5Cert.ca_chain
            Cert = vault_pki_secret_backend_cert.OpenSearchData5Cert.certificate
            Key = vault_pki_secret_backend_cert.OpenSearchData5Cert.private_key
          }
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