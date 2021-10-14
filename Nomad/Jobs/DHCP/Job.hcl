job "dhcp" {
  datacenters = ["core0site1", "home1"]

  group "dhcp" {
    count = 4

    network {
      mode = "cni/nomadcore1"

      port "dhcp" {
        to = 67
      }

      port "metrics" {
        to = 9547
      }
    }

    service {
      name = "dhcp"
      port = "dhcp"

      task = "kea-dhcp-server"

      address_mode = "alloc"

      check {
        name = "Kea Control Health healthcheck"

        address_mode = "alloc"
        port     = 8000
        type     = "tcp"
        interval = "20s"
        timeout  = "5s"
        
        check_restart {
          limit           = 3
          grace           = "60s"
          ignore_warnings = false
        }
      }
    }

    service {
      name = "dhcp-metrics"
      port = "metrics"

      task = "kea-dhcp-server"

      address_mode = "alloc"
    }

    task "dhcp-db" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "docker"

      config {
        image = "postgres:alpine3.14"

        command = "/usr/local/bin/psql"

        args = ["--file=/local/dhcp.psql", "--host=${Database.Hostname}", "--username=${Database.Username}", "${Database.Database}"]
      }

      env {
        PGPASSFILE = "/secrets/.pgpass"
      }

      template {
        data = <<EOH
${PSQL_INIT}
EOH

        destination = "local/dhcp.psql"
      }

      template {
        data = <<EOH
${Database.Hostname}:5432:${Database.Database}:${Database.Username}:${Database.Password}
EOH

        perms = "600"

        destination = "secrets/.pgpass"
      }
    }

    task "kea-dhcp-server" {
      driver = "docker"

      config {
        image = "kristianfjones/kea:vps1-core"

        tty = true

        command = "/local/entry.sh"

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }

      #
      # DHCP Config
      #

      # DHCP4
      template {
        data = <<EOF
${DHCP4.Config}
EOF

        destination = "local/DHCP4.jsonc"
      }

      # DHCP6
      template {
        data = <<EOF
${DHCP6.Config}
EOF

        destination = "local/DHCP6.jsonc"
      }

      #
      # Kea CTRL
      #

      # Kea CTRL Config
      template {
        data = <<EOF
${KeaCTRL.Config}
EOF

        destination = "local/keactrl.conf"
      }

      # Kea CTRL Agent Config
      template {
        data = <<EOF
${KeaCTRL.AgentConfig}
EOF

        destination = "local/kea-ctrl-agent.jsonc"
      }


      # Entrypoint Script
      template {
        data = <<EOF
${EntryScript}
EOF

        destination = "local/entry.sh"

        perms = "777"
      }
    }
  }
}