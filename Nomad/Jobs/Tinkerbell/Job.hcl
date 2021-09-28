job "tinkerbell" {
  datacenters = ["core0site1"]

  group "tink" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { }

      port "grpc" { }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "tink-grpc-cont"
      port = "health"

      task = "tink-server"

      address_mode = "alloc"
    }

    task "tink-server" {
      driver = "docker"

      config {
        image = "quay.io/tinkerbell/tink:${Version}"

        args = ["-conf=/local/Corefile"]
      }


      template {
        data = <<EOH
#
# Database
#
PGDATABASE="${Database.Database}"
PGHOST="${Database.Hostname}"
PGPORT="${Database.Port}"

PGUSER="${Database.Username}"
PGPASSWORD="${Database.Password}"


EOH

        destination = "secrets/file.env"
        env         = true
      }

      template {
        data = <<EOH
${TLS.CA}
EOH

        destination = "secrets/ca.pem"
      }

      template {
        data = <<EOH
${TLS.Cert}
EOH

        destination = "secrets/tink.pem"
      }

      template {
        data = <<EOH
${TLS.Key}
EOH

        destination = "secrets/tink.key"
      }
    }
  }

  group "Boots" {

  }

  group "hegel" {

  }

  group "PBnJ" {

  }
}