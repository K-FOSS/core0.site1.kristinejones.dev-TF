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

        memory_hard_limit = 2048

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=migrations"
          }
        }
      }

      resources {
        cpu = 128

        memory = 512
        memory_max = 2048
      }

      env {
        #
        # Config
        #
        CONFIG_TEMPLATE_DIRECTORY = "/local/configtemplates"
        CONFIG_DIRECTORY = "/srv/gitlab/config"

        BYPASS_SCHEMA_VERSION = "true"

        GITLAB_ROOT_PASSWORD = "RANDOM_PASS5859!!"

        EXTERNAL_URL = "https://gitlab.kristianjones.dev"

        GITLAB_HOST = "https://gitlab.kristianjones.dev"
        GITLAB_PORT = "443"

        #
        # Rails
        #
        ENABLE_BOOTSNAP = "1"
      }

      #
      # Configs
      #
      
      #
      # GitLab YAML
      #
      template {
        data = <<EOF
${GitLab.Configs.GitLab}
EOF

        destination = "local/configtemplates/gitlab.yml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${GitLab.Configs.Cable}
EOF

        destination = "local/configtemplates/cable.yml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${GitLab.Configs.Database}
EOF

        destination = "local/configtemplates/database.yml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${GitLab.Configs.Resque}
EOF

        destination = "local/configtemplates/resque.yml"

        change_mode = "noop"
      }

      #
      # Secrets YAML
      #
      template {
        data = <<EOF
production:
  secret_key_base: ${Secrets.SecretKeyBase}
  db_key_base: ${Secrets.DatabaseKeyBase}
  otp_key_base: ${Secrets.OTPKeyBase}
  encrypted_settings_key_base: ${Secrets.DatabaseKeyBase}
  openid_connect_signing_key: |
    ${Secrets.OpenIDSigningKey}
  ci_jwt_signing_key: |
    ${Secrets.OpenIDSigningKey}
EOF

        destination = "local/configtemplates/secrets.yml"

        change_mode = "noop"
      }

      #
      # Shared Secrets
      #

      template {
        data = "${Secrets.WorkHorse}"

        destination = "secrets/.gitlab_workhorse_secret"

        change_mode = "noop"
      }

      template {
        data = "${Secrets.Shell}"

        destination = "secrets/.gitlab_shell_secret"

        change_mode = "noop"
      }

      template {
        data = "${Secrets.KAS}"

        destination = "secrets/.gitlab_kas_secret"

        change_mode = "noop"
      }
    }
  }
}