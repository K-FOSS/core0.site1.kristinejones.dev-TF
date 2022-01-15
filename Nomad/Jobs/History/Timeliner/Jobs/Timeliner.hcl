job "history-timeliner" {
  datacenters = ["core0site1"]

  group "timeliner-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"
    }

    service {
      name = "ejabberd"
      port = "s2s"

      task = "ejabberd"
      address_mode = "alloc"

      tags = ["coredns.enabled", "$${NOMAD_ALLOC_INDEX}"]
    }

    service {
      name = "ejabberd"
      port = "mqtt"

      task = "ejabberd"
      address_mode = "alloc"

      tags = ["coredns.enabled", "mqtt"]
    }

    task "timeliner" {
      driver = "docker"

      config {
        image = "${Timeliner.Image.Repo}:${Timeliner.Image.Tag}"

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
{{ $Count := env "NOMAD_ALLOC_INDEX" }}{{ if ne $Count "0" }}CTL_ON_CREATE="join_cluster ejabberd@0.ejabberd.service.kjdev"{{ end }}
ERLANG_NODE="{{ env "NOMAD_ALLOC_INDEX" }}.ejabberd.service.kjdev"
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