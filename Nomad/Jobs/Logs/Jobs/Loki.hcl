job "loki" {
  datacenters = ["core0site1"]

  group "loki-memcached" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "memcached" { 
        to = 11211
      }
    }

    service {
      name = "loki-memcached"
      port = "memcached"

      task = "memcached"
      address_mode = "alloc"

      tags = ["coredns.enabled"]
    }

    task "memcached" {
      driver = "docker"

      config {
        image = "memcached:1.6"
      }
    }
  }

%{ for Target in Loki.Targets ~}
  group "loki-${Target.name}" {
    count = ${Target.count}

    spread {
      attribute = "$${node.unique.id}"
      weight    = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "grpc" { 
        to = 8085
      }

      port "gossip" { 
        to = 8090
      }
    }

    service {
      name = "loki-${Target.name}-http-cont"
      port = "http"

      task = "loki-${Target.name}"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled"]

      #
      # Liveness check
      #
      check {
        port = "http"
        address_mode = "alloc"

        type = "http"

        path = "/ready"
        interval = "15s"
        timeout  = "3s"

        check_restart {
          limit = 10
          grace = "10m"
        }
      }
    }

    service {
      name = "loki-${Target.name}-grpc-cont"
      port = "grpc"

      task = "loki-${Target.name}"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled"]
    }

    service {
      name = "loki-${Target.name}-gossip-cont"
      
      port = "gossip"
      address_mode = "alloc"

      task = "loki-${Target.name}"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled"]
    }

    task "loki-${Target.name}" {
      driver = "docker"

      resources {
        cpu = ${Target.resources.cpu}
        memory = ${Target.resources.memory}
        memory_max = ${Target.resources.memory_max}
      }

      restart {
        attempts = 5
        delay = "60s"
      }

      config {
        image = "grafana/loki:${Loki.Version}"

        args = ["-config.file=/local/Loki.yaml"]

        memory_hard_limit = ${Target.resources.memory_max}
      }

      meta {
        TARGET = "${Target.name}"

        REPLICAS = "${Target.count}"
      }

      template {
        data = <<EOF
${Loki.YAMLConfig}
EOF

        destination = "local/Loki.yaml"
      }
    }
  }
%{ endfor ~}
}