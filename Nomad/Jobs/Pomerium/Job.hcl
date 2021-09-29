job "pomerium" {
  datacenters = ["core0site1"]

  group "pomerium-server" {
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
      name = "pomerium-cont"
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
${CONFIG}
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