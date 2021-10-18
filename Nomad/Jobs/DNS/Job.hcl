job "dns" {
  datacenters = ["core0site1"]

  group "coredns" {
    count = 3

    network {
      mode = "cni/nomadcore1"

      port "dns" { }

      port "health" { }

      port "netdns" {
        static = 5330

        to = 5330
      }

      port "netdnshealth" { }
    }

    service {
      name = "coredns-health-cont"
      port = "health"

      task = "coredns-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      check {
        name = "CoreDNS Health healthcheck"

        address_mode = "alloc"
        port = "health"

        type = "http"
        path = "/health"

        interval = "20s"
        timeout  = "5s"
        
        check_restart {
          limit = 3
          grace = "60s"
          ignore_warnings = false
        }
      }
    }

    service {
      name = "coredns-dns-cont"
      port = "dns"

      task = "coredns-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      check {
        name = "CoreDNS DNS healthcheck"

        address_mode = "alloc"
        port = "health"
        type = "http"
        path = "/health"
        interval = "20s"
        timeout  = "5s"
        
        check_restart {
          limit = 3
          grace = "60s"
          ignore_warnings = false
        }
      }
    }

    service {
      name = "coredns-netdns-cont"
      port = "netdns"

      task = "coredns-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      check {
        name = "CoreDNS DNS healthcheck"

        address_mode = "alloc"
        port = "netdnshealth"
        type = "http"
        path = "/health"
        interval = "20s"
        timeout  = "5s"
        
        check_restart {
          limit = 3
          grace = "60s"
          ignore_warnings = false
        }
      }
    }

    task "coredns-server" {
      driver = "docker"

      config {
        image = "kristianfjones/coredns-docker:core0"

        args = ["-conf=/local/Corefile"]
      }

      template {
        data = <<EOF
${CoreFile}
EOF

        destination = "local/Corefile"
      }

      template {
        data = <<EOF
${PluginsConfig}
EOF

        destination = "local/plugin.cfg"
      }
    }
  }

  group "powerdns" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "dns" {
        to = 53
      }
    }

    service {
      name = "powerdns"
      port = "dns"

      task = "powerdns-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}"]
    }

    task "powerdns-db" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "docker"

      config {
        image = "postgres:alpine3.14"

        command = "/usr/local/bin/psql"

        args = ["--file=/local/dns.psql", "--host=${PowerDNS.Database.Hostname}", "--username=${PowerDNS.Database.Username}", "${PowerDNS.Database.Database}"]
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
${PowerDNS.Database.Hostname}:5432:${PowerDNS.Database.Database}:${PowerDNS.Database.Username}:${PowerDNS.Database.Password}
EOH

        perms = "600"

        destination = "secrets/.pgpass"
      }
    }

    task "coredns-server" {
      driver = "docker"

      config {
        image = "powerdns/pdns-auth-master"

        args = ["--config-dir=/local/"]
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