job "development-gitlab-webservice" {
  datacenters = ["core0site1"]

 #
  # GitLab Web Service
  #
  group "gitlab-webservice" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" { 
        to = 443
      }
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

    service {
      name = "gitlab"
      port = "https"

      task = "gitlab-webservice-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.webservice"]
    }

    task "gitlab-webservice-server" {
      driver = "docker"

      user = "root"

      config {
        image = "${Image.Repo}/gitlab-webservice-ce:${Image.Tag}"

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

        mount {
          type = "bind"
          target = "/opt/gitlab/embedded/ssl/certs/gitlab.pem"
          source = "secrets/TLS/CA.pem"
          readonly = false
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=webservice"
          }
        }
      }

      resources {
        cpu = 812
        memory = 4096
        memory_max = 4096
      }

      env {
        #
        # 
        #
        GITLAB_WEBSERVER = "PUMA"

        INTERNAL_PORT = "443"


        #
        # Configs
        #
        CONFIG_TEMPLATE_DIRECTORY = "/var/opt/gitlab/config/templates"
        CONFIG_DIRECTORY = "/srv/gitlab/config"

        EXTERNAL_URL = "https://gitlab.kristianjones.dev"

        GITLAB_HOST = "https://gitlab.kristianjones.dev"
        GITLAB_PORT = "443"
        GITLAB_SSH_PORT = "2222"

        GITALY_FEATURE_DEFAULT_ON = "1"

        ACTION_CABLE_IN_APP = "true"

        REGISTRY_PORT = "5000"

        WAIT_FOR_TIMEOUT = "60"

        GITLAB_ROOT_PASSWORD = "RANDOM_PASS5859!!"

        ENABLE_BOOTSNAP = "1"

        PUMA_WORKER_MAX_MEMORY = "1024"

        GITLAB_TRACING = "opentracing://jaeger?http_endpoint=http%3A%2F%2Fhttp.distributor.tempo.service.kjdev%3A14268%2Fapi%2Ftraces&sampler=const&sampler_param=1"

        #
        # TLS
        #SSL_CERT_FILE
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

      template {
        data = <<EOF
${WebService.TLS.CA}
EOF

        destination = "secrets/TLS/CA.pem"
      }

      template {
        data = <<EOF
${WebService.TLS.Cert}
EOF

        destination = "secrets/TLS/Cert.pem"
      }

      template {
        data = <<EOF
${WebService.TLS.Key}
EOF

        destination = "secrets/TLS/Cert.key"
      }
    }
  }

}