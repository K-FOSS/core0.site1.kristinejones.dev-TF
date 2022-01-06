job "development-gitlab-shell" {
  datacenters = ["core0site1"]

  priority = 90

  #
  # GitLab Shell
  #
  group "gitlab-shell" {
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

      task = "gitlab-shell-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.shell"]

      #
      # Liveness check
      #
      check {
        type = "script"
        command = "/scripts/healthcheck"

        interval = "10s"
        timeout  = "3s"

        check_restart {
          limit = 12
          grace = "60s"
          ignore_warnings = false
        }
      }
    }

    task "gitlab-shell-server" {
      driver = "docker"

      config {
        image = "${Image.Repo}/gitlab-shell:${Image.Tag}"

        memory_hard_limit = 512

        mount {
          type = "tmpfs"
          target = "/srv/gitlab/config"
          readonly = false
          tmpfs_options = {
            size = 100000
          }
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=shell"
          }
        }
      }

      resources {
        cpu = 256

        memory = 256
        memory_max = 512
      }

      env {
        CONFIG_TEMPLATE_DIRECTORY = "/local/configtemplates"

        CONFIG_DIRECTORY = "/srv/gitlab/config"

        #
        # Misc
        #
        GITLAB_HOST = "https://git.writemy.codes"
        GITLAB_PORT = "443"

        #
        # Gitaly
        #
        GITALY_FEATURE_DEFAULT_ON = "1"

        #
        # Observability
        #

        GITLAB_TRACING = "opentracing://jaeger?http_endpoint=http%3A%2F%2Fhttp.distributor.tempo.service.kjdev%3A14268%2Fapi%2Ftraces&sampler=const&sampler_param=1"
      }

      template {
        data = <<EOF
${Shell.Config}
EOF

        destination = "local/configtemplates/config.yaml.erb"
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