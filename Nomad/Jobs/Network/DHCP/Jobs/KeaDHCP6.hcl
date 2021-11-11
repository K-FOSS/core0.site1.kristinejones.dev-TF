job "network-dhcp-keadhcp6" {
  datacenters = ["core0site1"]

  group "dhcp" {
    count = 4

    network {
      mode = "cni/nomadcore1"

      port "dhcp" {
        to = 67
      }

      port "http" {
        to = 8000
      }
    }

    service {
      name = "keadhcp"
      port = "dhcp"

      task = "kea-dhcp-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "dhcp.dhcp6"]
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

        args = ["--file=/local/dhcp.psql", "--host=${Database.Hostname}", "--username=${Database.Username}", "--port=${Database.Port}", "${Database.Database}"]
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
${Database.Hostname}:${Database.Port}:${Database.Database}:${Database.Username}:${Database.Password}
EOH

        perms = "600"

        destination = "secrets/.pgpass"
      }
    }

    task "kea-dhcp6-server" {
      driver = "docker"

      config {
        image = "kristianfjones/kea:vps1-core"
        entrypoint = [""]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=dhcp,service=kea-dhcp4"
          }
        }
      }

      #
      # DHCP Config
      #

      # DHCP6
      template {
        data = <<EOF
${DHCP6.Config}
EOF

        destination = "local/DHCP6.jsonc"
      }

      resources {
        cpu = 32
        memory = 32
        memory_max = 64
      }
    }
  }
}