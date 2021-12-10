job "misc-ivatar" {
  datacenters = ["core0site1"]

  group "ivatar" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8000
      }
    }

    service {
      name = "ivatar"
      port = "http"

      task = "ivatar-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]
    }

    task "ivatar-db" {
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

    task "ivatar-server" {
      driver = "docker"

      config {
        image = "registry.kristianjones.dev/cache/mpepping/cyberchef:latest"
      }

      resources {
        cpu = 64
        memory = 32
        memory_max = 32
      }

      template {
        data = <<EOH
#
# Database
#
DATABASE_URL="postgres://${Outline.Database.Username}:${Outline.Database.Password}@${Outline.Database.Hostname}:${Outline.Database.Port}/${Outline.Database.Database}?pool=20&encoding=unicode&reconnect=true"
EOH

        destination = "secrets/file.env"
        env = true
      }
    }
  }
}