job "dns" {
  datacenters = ["core0site1"]

  group "coredns" {
    count = 6

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "dns" { }

      port "health" { }

      port "netdns" {
        to = 5330
      }

      port "netdnshealth" { }
    }

    service {
      name = "coredns-health-cont"
      port = "health"

      task = "coredns-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      check {
        name = "CoreDNS Health healthcheck"

        address_mode = "alloc"
        port = "health"

        type = "http"
        path = "/health"

        interval = "20s"
        timeout  = "5s"
        
        check_restart {
          limit = 3
          grace = "60s"
          ignore_warnings = false
        }
      }
    }

    service {
      name = "coredns-dns-cont"
      port = "dns"

      task = "coredns-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      check {
        name = "CoreDNS DNS healthcheck"

        address_mode = "alloc"
        port = "health"
        type = "http"
        path = "/health"
        interval = "20s"
        timeout  = "5s"
        
        check_restart {
          limit = 3
          grace = "60s"
          ignore_warnings = false
        }
      }
    }

    service {
      name = "coredns-netdns-cont"
      port = "netdns"

      task = "coredns-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      check {
        name = "CoreDNS DNS healthcheck"

        address_mode = "alloc"
        port = "netdnshealth"
        type = "http"
        path = "/health"
        interval = "20s"
        timeout  = "5s"
        
        check_restart {
          limit = 3
          grace = "60s"
          ignore_warnings = false
        }
      }
    }

    task "coredns-server" {
      driver = "docker"

      config {
        image = "kristianfjones/coredns-docker:core0"

        args = ["-conf=/local/Corefile"]
      }

      template {
        data = <<EOF
${CoreFile}
EOF

        destination = "local/Corefile"
      }

      template {
        data = <<EOF
${PluginsConfig}
EOF

        destination = "local/plugin.cfg"
      }

      resources {
        cpu = 64
        memory = 64
        memory_max = 128
      }
    }
  }
}