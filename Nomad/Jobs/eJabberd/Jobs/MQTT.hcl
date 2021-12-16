job "ejabberd-mqtt" {
  datacenters = ["core0site1"]

  group "ejabberd-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "ejabberd"
      port = "redis"

      task = "redis"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6-alpine3.14"

        command = "redis-server"

        args = ["/local/redis.conf"]
      }

      template {
        data = <<EOF
port 6379

requirepass "${Redis.Password}"
EOF

        destination = "local/redis.conf"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${TLS.Redis.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.Redis.Key}
EOF

        destination = "local/cert.key"
      }
    }
  }

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

        args = ["--file=/local/init.psql", "--host=${Database.Hostname}", "--username=${Database.Username}", "--port=${Database.Port}", "${Database.Database}"]
      }

      env {
        PGPASSFILE = "/secrets/.pgpass"
      }

      template {
        data = <<EOH
${PSQL_INIT}
EOH

        destination = "local/init.psql"
      }

      template {
        data = <<EOH
${Database.Hostname}:${Database.Port}:${Database.Database}:${Database.Username}:${Database.Password}
EOH

        perms = "600"

        destination = "secrets/.pgpass"
      }
    }

    task "ejabberd" {
      driver = "docker"

      config {
        image = "ejabberd/ecs:${Version}"

        args = ["--config", "/local/eJabberD.yaml", "foreground"]
      }

      template {
        data = <<EOF
${eJabberD.Config}
EOF

        destination = "local/eJabberD.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${TLS.MQTT.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.MQTT.Key}
EOF

        destination = "local/cert.key"
      }

      resources {
        cpu = 128
        memory = 128
      }
    }
  }
}