job "inventory-meshcentral-core" {
  datacenters = ["core0site1"]

  group "meshcentral-core" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" { 
        to = 443
      }

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    service {
      name = "meshcentral"
      port = "https"

      task = "meshcentral-core-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.server"]
    }

    task "meshcentral-core-server" {
      driver = "docker"

      config {
        image = "goauthentik.io/ldap:${Version}"

        memory_hard_limit = 256
      }

      env {
        AUTHENTIK_HOST = "${LDAP.AuthentikHost}"

        AUTHENTIK_INSECURE = "false"
      }

      template {
        data = <<EOH

EOH

        destination = "secrets/file.env"
        env = true
      }

      resources {
        cpu = 32

        memory = 64
        memory_max = 256
      }
    }
  }
}