job "aaa-teleport-proxys" {
  datacenters = ["core0site1"]

  group "teleport-proxy" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    update {
      max_parallel = 1

      health_check = "checks"
      
      min_healthy_time = "30s"

      healthy_deadline = "3m"

      progress_deadline = "8m"
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 443
      }

      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "teleport"
      port = "https"

      task = "teleport-auth-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "https.proxy"]
    }

    task "teleport-proxy-server" {
      driver = "docker"

      config {
        image = "${Teleport.Repo}:${Teleport.Version}"

        args = ["start", "--config", "/local/Teleport.yaml"]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=teleport,service=auth"
          }
        }
      }

      env {
      }

      resources {
        cpu = 256

        memory = 256
      }

      template {
        data = <<EOF
${Teleport.YAMLConfig}
EOF

        destination = "local/Teleport.yaml"
      }
    }
  }
}