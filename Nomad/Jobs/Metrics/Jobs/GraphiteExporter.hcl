job "graphite" {
  datacenters = ["core0site1"]

  group "graphite-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "metrics" {
        to = 9108
      }

      port "graphite" {
        to = 2003
      }

      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "graphite"
      port = "metrics"

      task = "graphite-exporter"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "metrics"]
    }

    service {
      name = "graphite"
      port = "graphite"

      task = "graphite-exporter"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "graphite"]
    }

    task "graphite-exporter" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "60s"
      }

      config {
        image = "prom/graphite-exporter:${Version}"

        args = ["--graphite.mapping-config=/local/graphite.yaml", "--graphite.listen-address=0.0.0.0:2003"]

        memory_hard_limit = 128
      }

      resources {
        cpu = 128
        memory = 128
        memory_max = 128
      }

      template {
        data = <<EOF
${YAMLConfig}
EOF

        destination = "local/graphite.yaml"
        
        # Config Replacement
        change_mode = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}