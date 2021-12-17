job "network-lookingglass-server" {
  datacenters = ["core0site1"]

  priority = 100

  group "lookingglass-server" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 80
      }

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    service {
      name = "lookingglass"
      port = "http"

      task = "lookingglass-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]
    }

    task "lookingglass-server" {
      driver = "docker"

      config {
        image = "registry.kristianjones.dev/cache/gmazoyer/looking-glass:latest"

        mount {
          type = "bind"
          target = "/var/www/html/config.php"
          source = "local/config.php"
          readonly = true
        }
      }

      template {
        data = <<EOF
${LookingGlass.Config}
EOF

        destination = "local/config.php"
      }

      resources {
        cpu = 256
        memory = 512
        memory_max = 512
      }
    }
  }
}