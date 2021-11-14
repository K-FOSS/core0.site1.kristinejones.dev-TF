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

        command = "/scripts/wait-for-deps"

        args = ["/scripts/db-migrate"]

        mount {
          type = "bind"
          target = "/var/opt/gitlab/config/secrets/.gitlab_shell_secret"
          source = "secrets/shell/.gitlab_shell_secret"
          readonly = true
        }

        mount {
          type = "bind"
          target = "/var/opt/gitlab/config/templates"
          source = "local/webservice/configtemplates"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
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

        GITLAB_ROOT_PASSWORD = "RANDOM_PASS5859!!"
      }

      template {
        data = <<EOF
${WebService.Templates.Cable}
EOF

        destination = "local/webservice/configtemplates/cable.yml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.Database}
EOF

        destination = "local/webservice/configtemplates/database.yml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.GitlabERB}
EOF

        destination = "local/webservice/configtemplates/gitlab.yml.erb"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.Resque}
EOF

        destination = "local/webservice/configtemplates/resque.yml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.Secrets}
EOF

        destination = "local/webservice/configtemplates/secrets.yml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
6fad933c6267760415116fc4f35d2c7fc969f4ce0c162b49c3dd7be5517283e63000340ba7282dd97c2b3518b6d3c97a7cdd995dcb6f00dff11cf0aa316a459f
EOF

        destination = "secrets/shell/.gitlab_shell_secret"

        change_mode = "noop"
      }
    }
  }
}