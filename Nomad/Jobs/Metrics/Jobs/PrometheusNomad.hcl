job "prometheus-nomad" {
  datacenters = ["core0site1"]

  group "prometheus-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "prometheus_ui" {
        static = 9090

        host_network = "node"
      }

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13" 
        ]
      }
    }

    ephemeral_disk {
      size = 300
    }

    task "prometheus" {
      driver = "docker"

      restart {
        attempts = 2
        interval = "30m"
        delay = "15s"
        mode = "fail"
      }

      config {
        image = "prom/prometheus:${Prometheus.Version}"

        args = ["--config.file=/local/prometheus.yaml", "--enable-feature=exemplar-storage"]

        ports = ["prometheus_ui"]
      }

      service {
        name = "prometheus"
        tags = ["urlprefix-/"]
        port = "prometheus_ui"

        check {
          name = "prometheus_ui port alive"
          type = "http"
          path = "/-/healthy"
          interval = "10s"
          timeout = "2s"
        }
      }

      resources {
        cpu = 892
        memory = 2048
        memory_max = 2048
      }

      template {
        change_mode = "noop"
        destination = "local/prometheus.yaml"

        data = <<EOH
---
global:
  scrape_interval: 5s
  evaluation_interval: 5s

scrape_configs:

  - job_name: 'nomad_metrics'

    consul_sd_configs:
      - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
        services: ['NomadClient', 'NomadServer']

    relabel_configs:
      - source_labels: ['__meta_consul_tags']
        regex: '(.*)http(.*)'
        action: keep

    scrape_interval: 5s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']

remote_write:
  - url: http://http.distributor.cortex.service.kjdev:8080/api/v1/push
    send_exemplars: true
    remote_timeout: 60s
EOH
      }
    }
  }
}