job "dns" {
  datacenters = ["core0site1"]

  group "coredns" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "dns" { }

      port "health" { }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "coredns-health-cont"
      port = "health"

      task = "coredns-server"

      address_mode = "alloc"

      check {
        name     = "CoreDNS Health healthcheck"

        address_mode = "alloc"
        port     = "health"
        type     = "http"
        path     = "/health"
        interval = "20s"
        timeout  = "5s"
        
        check_restart {
          limit           = 3
          grace           = "60s"
          ignore_warnings = false
        }
      }
    }

    service {
      name = "coredns-dns-cont"
      port = "dns"

      task = "coredns-server"

      address_mode = "alloc"

      check {
        name     = "CoreDNS DNS healthcheck"

        address_mode = "alloc"
        port     = "health"
        type     = "http"
        path     = "/health"
        interval = "20s"
        timeout  = "5s"
        
        check_restart {
          limit           = 3
          grace           = "60s"
          ignore_warnings = false
        }
      }
    }

    task "coredns-server" {
      driver = "docker"

      config {
        image = "coredns/coredns:${Version}"

        args = ["-conf=/local/Corefile"]
      }

      template {
        data = <<EOF
${CoreFile}
EOF

        destination = "local/Corefile"
      }
    }
  }
}