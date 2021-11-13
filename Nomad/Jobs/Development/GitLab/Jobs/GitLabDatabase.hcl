job "gitlab-database" {
  datacenters = ["core0site1"]

  #
  # GitLab Migrations
  #
  group "gitlab-migrations" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"
    }

    task "wait-for-gitlab-redis" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z redis.gitlab.service.dc1.kjdev 6379; do sleep 1; done"]
      }
    }

    task "gitlab-migrations-task" {
      driver = "docker"

      lifecycle {
        hook = "poststart"
        sidecar = false
      }

      config {
        image = "${Image.Repo}/gitlab-rails-ce:${Image.Tag}"

        command = "/scripts/db-migrate"
      }

      resources {
        cpu = 128
        memory = 512
        memory_max = 512
      }

      env {
        CONFIG_TEMPLATE_DIRECTORY = "/var/opt/gitlab/config/templates"
        CONFIG_DIRECTORY = "/srv/gitlab/config"

        BYPASS_SCHEMA_VERSION = "true"
      }

      template {
        data = <<EOF
${WebService.Templates.Cable}
EOF

        destination = "local/webservice/configtemplates/cable.yaml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.Database}
EOF

        destination = "local/webservice/configtemplates/database.yaml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.GitlabYML}
EOF

        destination = "local/webservice/configtemplates/gitlab.yml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.Resque}
EOF

        destination = "local/webservice/configtemplates/resque.yaml"

        change_mode = "noop"
      }
    }
  }
}