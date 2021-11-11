job "network-dhcp-keadhcp4" {
  datacenters = ["core0site1"]

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

      port "controlagent" {
        to = 8000
      }
    }

    service {
      name = "keadhcp"
      port = "dhcp"

      task = "kea-dhcp-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "dhcp.dhcp4"]
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

    task "kea-dhcp4-server" {
      driver = "docker"

      config {
        image = "kristianfjones/kea:vps1-core"
        Entrypoint = ["/usr/sbin/kea-dhcp4"]

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

      # DHCP4
      template {
        data = <<EOF
${DHCP4.Config}
EOF

        destination = "local/DHCP4.jsonc"
      }

      resources {
        cpu = 32
        memory = 32
        memory_max = 64
      }
    }
  }
}