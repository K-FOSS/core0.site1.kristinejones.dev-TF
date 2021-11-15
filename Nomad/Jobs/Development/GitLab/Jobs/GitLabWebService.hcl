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

      port "http" { 
        to = 8080
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
    }

    service {
      name = "gitlab"
      port = "http"

      task = "gitlab-webservice-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.webservice"]
    }

    task "gitlab-webservice-server" {
      driver = "docker"

      user = "root"

      config {
        image = "${Image.Repo}/gitlab-webservice-ce:${Image.Tag}"

        command = "/scripts/wait-for-deps"

        args = ["/scripts/process-wrapper"]

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
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=webservice"
          }
        }
      }

      resources {
        cpu = 256
        memory = 2048
        memory_max = 2048
      }

      env {
        #
        # 
        #
        GITLAB_WEBSERVER = "PUMA"

        INTERNAL_PORT = "8080"


        #
        # Configs
        #
        CONFIG_TEMPLATE_DIRECTORY = "/var/opt/gitlab/config/templates"
        CONFIG_DIRECTORY = "/srv/gitlab/config"

        EXTERNAL_URL = "https://gitlab.int.site1.kristianjones.dev"

        GITLAB_HOST = "localhost"
        GITLAB_PORT = "443"
        GITLAB_SSH_PORT = "2222"

        GITALY_FEATURE_DEFAULT_ON = "1"

        ACTION_CABLE_IN_APP = "true"

        REGISTRY_PORT = "5000"

        WAIT_FOR_TIMEOUT = "60"

        GITLAB_ROOT_PASSWORD = "RANDOM_PASS5859!!"

        ENABLE_BOOTSNAP = "1"

        PUMA_WORKER_MAX_MEMORY = "1024"
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

      template {
        data = "${WebService.Secrets.WorkHorse}"

        destination = "secrets/workhorse/.gitlab_workhorse_secret"

        change_mode = "noop"
      }
    }
  }

}