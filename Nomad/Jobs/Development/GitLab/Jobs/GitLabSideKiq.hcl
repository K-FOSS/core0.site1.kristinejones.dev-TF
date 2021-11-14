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
        image = "${Image.Repo}/gitlab-sidekiq-ee:${Image.Tag}"

        command = "/scripts/wait-for-deps"

        args = ["/scripts/process-wrapper"]

        mount {
          type = "bind"
          target = "/var/opt/gitlab/config/templates"
          source = "local/sidekiq/templates"
          readonly = false
        }
      }

      resources {
        cpu = 256
        memory = 1024
        memory_max = 1024
      }

      env {
        CONFIG_TEMPLATE_DIRECTORY = "/var/opt/gitlab/config/templates"

        CONFIG_DIRECTORY = "/srv/gitlab/config"

        WAIT_FOR_TIMEOUT = "60"

        GITLAB_HOST = "localhost"
        GITLAB_PORT = "3000"

        GITALY_FEATURE_DEFAULT_ON = "1"
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