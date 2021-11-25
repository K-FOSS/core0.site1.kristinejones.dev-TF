job "development-gitlab-sidekiq" {
  datacenters = ["core0site1"]

  #
  # GitLab Sidekiq
  #
  group "gitlab-sidekiq" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 8080
      }
    }

    service {
      name = "gitlab"
      port = "http"

      task = "gitlab-sidekiq-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.sidekiq"]
    }

    task "gitlab-sidekiq-server" {
      driver = "docker"

      user = "root"

      config {
        image = "${Image.Repo}/gitlab-sidekiq-ce:${Image.Tag}"

        mount {
          type = "bind"
          target = "/var/opt/gitlab/config/templates"
          source = "local/sidekiq/templates"
          readonly = false
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=sidekiq"
          }
        }
      }

      resources {
        cpu = 900
        memory = 2000
        memory_max = 2000
      }

      env {
        CONFIG_TEMPLATE_DIRECTORY = "/var/opt/gitlab/config/templates"

        CONFIG_DIRECTORY = "/srv/gitlab/config"

        WAIT_FOR_TIMEOUT = "60"

        GITLAB_HOST = "https://gitlab.int.site1.kristianjones.dev"
        GITLAB_PORT = "443"

        GITALY_FEATURE_DEFAULT_ON = "1"

        ENABLE_BOOTSNAP = "1"
      }

      template {
        data = <<EOF
${Sidekiq.Templates.Database}
EOF

        destination = "local/sidekiq/templates/database.yml"
      }

      template {
        data = <<EOF
${Sidekiq.Templates.GitlabYAML}
EOF

        destination = "local/sidekiq/templates/gitlab.yml"
      }

      template {
        data = <<EOF
${Sidekiq.Templates.Resque}
EOF

        destination = "local/sidekiq/templates/resque.yml"
      }

      template {
        data = <<EOF
${Sidekiq.Templates.SidekiqQueues}
EOF

        destination = "local/sidekiq/templates/sidekiq_queues.yml"
      }
    }
  }
}