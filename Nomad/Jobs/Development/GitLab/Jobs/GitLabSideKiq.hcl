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
          target = "/opt/gitlab/embedded/ssl/certs/registry.pem"
          source = "local/TLS/RegistryCA.pem"
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
        memory = 1024
        memory_max = 1024
      }

      env {
        CONFIG_TEMPLATE_DIRECTORY = "/local/configtemplates"

        CONFIG_DIRECTORY = "/srv/gitlab/config"

        WAIT_FOR_TIMEOUT = "60"

        GITLAB_HOST = "https://gitlab.kristianjones.dev"
        GITLAB_PORT = "443"

        GITALY_FEATURE_DEFAULT_ON = "1"

        #
        # Rails
        #
        ENABLE_BOOTSNAP = "1"

        GITLAB_TRACING = "opentracing://jaeger?http_endpoint=http%3A%2F%2Fhttp.distributor.tempo.service.kjdev%3A14268%2Fapi%2Ftraces&sampler=const&sampler_param=1"
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
      # TLS
      #

      #
      # Registry
      #

      template {
        data = <<EOF
${TLS.Registry.CA}
EOF

        destination = "local/TLS/RegistryCA.pem"

        change_mode = "noop"
      }
    
      template {
        data = <<EOF
${TLS.Registry.Cert}
EOF

        destination = "secrets/TLS/Registry.pem"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${TLS.Registry.Key}
EOF
        destination = "secrets/TLS/Registry.key"

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