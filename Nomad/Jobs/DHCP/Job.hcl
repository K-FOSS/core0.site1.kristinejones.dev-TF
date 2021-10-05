job "dhcp" {
  datacenters = ["core0site1"]

  group "dhcp" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "dhcp" {
        to = 67
      }
    }

    service {
      name = "dhcp"
      port = "dhcp"

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

        args = ["--file=/local/dhcp.psql"]
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

        destination = "secrets/.pgpass"
      }
    }

    task "kea-dhcp-server" {
      driver = "docker"

      config {
        image = "kristianfjones/kea:vps1-core"

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

        destination = "local/kea-ctrl-agent.json"
      }


      # Entrypoint Script
      template {
        data = <<EOF
${EntryScript}
EOF

        destination = "local/entry.sh"
      }
    }
  }
}