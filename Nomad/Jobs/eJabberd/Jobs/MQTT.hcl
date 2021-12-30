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

      tags = ["coredns.enabled", "mqtt", "$${NOMAD_ALLOC_INDEX}"]
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
        image = "${eJabberD.Image.Repo}:${eJabberD.Image.Tag}"

        args = ["foreground"]

        memory_hard_limit = 256
      }

      env {
        #
        # Clustering
        #
        ERLANG_COOKIE = "${eJabberD.Secrets.eJabberDCookie}"

        EJABBERD_CONFIG_PATH = "/local/eJabberD.yaml"

        
      }

      template {
        data = <<EOH
{{ $Count := env "NOMAD_ALLOC_INDEX" }}{{ if ne $Count "0" }}"join_cluster ejabberd@0.ejabberd.service.kjdev"{{ end }}
CTL_ON_CREATE 
EOH

        destination = "secrets/file.env"
        env = true
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

        memory = 64
        memory_max = 256
      }
    }
  }
}