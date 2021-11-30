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

      resources {
        cpu = 16
        memory = 16
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

        mount {
          type = "bind"
          target = "/var/opt/gitlab/config/secrets/.gitlab_shell_secret"
          source = "secrets/shell/.gitlab_shell_secret"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/srv/gitlab/.gitlab_workhorse_secret"
          source = "secrets/workhorse/.gitlab_workhorse_secret"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/var/opt/gitlab/config/templates"
          source = "local/webservice/configtemplates"
          readonly = false
        }


        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=migrations"
          }
        }
      }

      resources {
        cpu = 1024
        memory = 2048
        memory_max = 2048
      }

      env {
        #
        # Config
        #
        CONFIG_TEMPLATE_DIRECTORY = "/var/opt/gitlab/config/templates"
        CONFIG_DIRECTORY = "/srv/gitlab/config"

        BYPASS_SCHEMA_VERSION = "true"

        GITLAB_ROOT_PASSWORD = "RANDOM_PASS5859!!"

        EXTERNAL_URL = "https://gitlab.kristianjones.dev"

        GITLAB_HOST = "https://gitlab.kristianjones.dev"
        GITLAB_PORT = "443"

        ENABLE_BOOTSNAP = "1"
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
${Secrets.Shell}
EOF

        destination = "secrets/shell/.gitlab_shell_secret"

        change_mode = "noop"
      }

      template {
        data = "${Secrets.KAS}"

        destination = "secrets/KAS/.gitlab_kas_secret"

        change_mode = "noop"
      }

      template {
        data = "${Secrets.WorkHorse}"

        destination = "secrets/workhorse/.gitlab_workhorse_secret"

        change_mode = "noop"
      }
    }
  }
}