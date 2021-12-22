job "ejabberd-mqtt" {
  datacenters = ["core0site1"]

  group "ejabberd-mqtt-server" {
    count = 3

    network {
      mode = "cni/nomadcore1"

      port "mqtt" { 
        to = 1883
      }
    }

    service {
      name = "ejabberd"
      port = "mqtt"

      task = "ejabberd"
      address_mode = "alloc"

      tags = ["coredns.enabled", "mqtt"]
    }

    task "ejabberd-db" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "docker"

      config {
        image = "postgres:alpine3.14"

        command = "/usr/local/bin/psql"

        args = ["--file=/local/init.psql", "--host=${eJabberD.Database.Hostname}", "--username=${eJabberD.Database.Username}", "--port=${eJabberD.Database.Port}", "${eJabberD.Database.Database}"]
      }

      env {
        PGPASSFILE = "/secrets/.pgpass"
      }

      template {
        data = <<EOH
${eJabberD.DatabaseInit}
EOH

        destination = "local/init.psql"
      }

      template {
        data = <<EOH
${eJabberD.Database.Hostname}:${eJabberD.Database.Port}:${eJabberD.Database.Database}:${eJabberD.Database.Username}:${eJabberD.Database.Password}
EOH

        perms = "600"

        destination = "secrets/.pgpass"
      }
    }

    task "ejabberd" {
      driver = "docker"

      config {
        image = "ejabberd/ecs:${eJabberD.Image.Tag}"

        args = ["--config", "/local/eJabberD.yaml", "foreground", "-setcookie=${eJabberD.Secrets.eJabberDCookie}"]

        memory_hard_limit = 512
      }

      template {
        data = <<EOF
${eJabberD.Config}
EOF

        destination = "local/eJabberD.yaml"
      }

      template {
        data = <<EOF
${eJabberD.TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${eJabberD.TLS.MQTT.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${eJabberD.TLS.MQTT.Key}
EOF

        destination = "local/cert.key"
      }

      resources {
        cpu = 128
        memory = 128
        memory_max = 512
      }
    }
  }
}