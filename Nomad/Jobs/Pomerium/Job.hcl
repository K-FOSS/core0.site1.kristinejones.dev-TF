job "pomerium" {
  datacenters = ["core0site1"]

  group "pomerium-authenticate" {
    count = 1

    network {
      mode = "bridge"

      port "http" { 
        to = 8080
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "pomerium-authenticate-http-cont"
      port = "http"

      task = "pomerium-server"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-server" {
      driver = "docker"

      config {
        image        = "pomerium/pomerium:latest"

        args = ["-config=/local/pomerium.yaml"]

        ports = ["http"]
      }

      template {
        data = <<EOF
${YAMLConfigs.Authenticate}
EOF

        destination = "local/pomerium.yaml"
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
      mode = "bridge"

      port "http" { 
        to = 8080
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "pomerium-authorize-http-cont"
      port = "http"

      task = "pomerium-server"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-server" {
      driver = "docker"

      config {
        image        = "pomerium/pomerium:latest"

        args = ["-config=/local/pomerium.yaml"]

        ports = ["http"]
      }

      template {
        data = <<EOF
${YAMLConfigs.Authorize}
EOF

        destination = "local/pomerium.yaml"
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
      mode = "bridge"

      port "http" { 
        to = 8080
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "pomerium-databroker-http-cont"
      port = "http"

      task = "pomerium-server"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-server" {
      driver = "docker"

      config {
        image        = "pomerium/pomerium:latest"

        args = ["-config=/local/pomerium.yaml"]

        ports = ["http"]
      }

      template {
        data = <<EOF
${YAMLConfigs.DataBroker}
EOF

        destination = "local/pomerium.yaml"
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
      mode = "bridge"

      port "http" { 
        to = 8080
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "pomerium-proxy-http-cont"
      port = "http"

      task = "pomerium-server"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "pomerium-server" {
      driver = "docker"

      config {
        image        = "pomerium/pomerium:latest"

        args = ["-config=/local/pomerium.yaml"]

        ports = ["http"]
      }

      template {
        data = <<EOF
${YAMLConfigs.Proxy}
EOF

        destination = "local/pomerium.yaml"
      }
      resources {
        cpu    = 800
        memory = 500
      }
    }
  }
}