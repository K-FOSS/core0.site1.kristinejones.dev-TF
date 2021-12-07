job "ns" {
  datacenters = ["core0site1"]

  group "powerdns" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }
    }

    service {
      name = "powerdns"
      port = "dns"

      task = "powerdns-admin-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "http.admin"]
    }

    task "powerdns-admin-db" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "docker"

      config {
        image = "postgres:alpine3.14"

        command = "/usr/local/bin/psql"

        args = ["--file=/local/dns.psql", "--host=${PowerDNS.Database.Hostname}", "--username=${PowerDNS.Database.Username}", "--port=${PowerDNS.Database.Port}", "${PowerDNS.Database.Database}"]
      }

      env {
        PGPASSFILE = "/secrets/.pgpass"
      }

      template {
        data = <<EOH
${PowerDNS.PSQL}
EOH

        destination = "local/dns.psql"
      }

      template {
        data = <<EOH
${PowerDNS.Database.Hostname}:${PowerDNS.Database.Port}:${PowerDNS.Database.Database}:${PowerDNS.Database.Username}:${PowerDNS.Database.Password}
EOH

        perms = "600"

        destination = "secrets/.pgpass"
      }
    }

    task "powerdns-admin-server" {
      driver = "docker"

      config {
        image = "powerdns/pdns-auth-master"

        ports = ["dns"]

        args = ["--config-dir=/local/"]
      }

      env {
        #
        # Server
        #
        PORT = "8080"
      }

      template {
        data = <<EOH
${PowerDNS.Config}
EOH

        destination = "local/pdns.conf"
      }
    }
  }
}