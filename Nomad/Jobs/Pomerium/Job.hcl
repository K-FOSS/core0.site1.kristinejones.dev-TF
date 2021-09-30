job "pomerium" {
  datacenters = ["core0site1"]

  group "pomerium-authenticate" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 443
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "pomerium-authenticate-cont"
      port = "http"

      task = "pomerium-server"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-server" {
      driver = "docker"

      config {
        image        = "pomerium/pomerium:${Version}"

        args = ["-config=/local/pomerium.yaml"]
      }

      template {
        data = <<EOF
${YAMLConfigs.Authenticate}
EOF

        destination = "local/pomerium.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/CA.pem"
      }

      template {
        data = <<EOF
${TLS.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.Key}
EOF

        destination = "local/cert.key"
      }

      resources {
        cpu    = 800
        memory = 500
      }
    }
  }

  group "pomerium-authorize" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 443
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "pomerium-authorize-cont"
      port = "http"

      task = "pomerium-server"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-server" {
      driver = "docker"

      config {
        image        = "pomerium/pomerium:${Version}"

        args = ["-config=/local/pomerium.yaml"]
      }

      template {
        data = <<EOF
${YAMLConfigs.Authorize}
EOF

        destination = "local/pomerium.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/CA.pem"
      }

      template {
        data = <<EOF
${TLS.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.Key}
EOF

        destination = "local/cert.key"
      }

      resources {
        cpu    = 800
        memory = 500
      }
    }
  }

  group "pomerium-databroker" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 443
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "pomerium-databroker-cont"
      port = "http"

      task = "pomerium-server"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-server" {
      driver = "docker"

      config {
        image        = "pomerium/pomerium:${Version}"

        args = ["-config=/local/pomerium.yaml"]
      }

      template {
        data = <<EOF
${YAMLConfigs.DataBroker}
EOF

        destination = "local/pomerium.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/CA.pem"
      }

      template {
        data = <<EOF
${TLS.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.Key}
EOF

        destination = "local/cert.key"
      }

      resources {
        cpu    = 800
        memory = 500
      }
    }
  }

  group "pomerium-proxy" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 443
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "pomerium-proxy-cont"
      port = "http"

      task = "pomerium-server"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-server" {
      driver = "docker"

      config {
        image        = "pomerium/pomerium:${Version}"

        args = ["-config=/local/pomerium.yaml"]
      }

      template {
        data = <<EOF
${YAMLConfigs.Proxy}
EOF

        destination = "local/pomerium.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/CA.pem"
      }

      template {
        data = <<EOF
${TLS.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.Key}
EOF

        destination = "local/cert.key"
      }

      resources {
        cpu    = 800
        memory = 500
      }
    }
  }
}