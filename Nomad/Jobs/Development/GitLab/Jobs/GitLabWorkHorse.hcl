job "development-gitlab-workhorse" {
  datacenters = ["core0site1"]

  #
  # GitLab WorkHorse
  #
  group "gitlab-workhorse" {
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

    task "wait-for-gitlab-webservice" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z http.webservice.gitlab.service.dc1.kjdev 8080; do sleep 1; done"]
      }
    }

    service {
      name = "gitlab"
      port = "http"

      task = "gitlab-workhorse-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.workhorse"]
    }

    task "gitlab-workhorse-server" {
      driver = "docker"

      config {
        image = "${Image.Repo}/gitlab-workhorse-ce:${Image.Tag}"

        command = "/scripts/start-workhorse"

        mount {
          type = "bind"
          target = "/etc/gitlab/gitlab-workhorse/secret"
          source = "secrets/workhorse/.gitlab_workhorse_secret"
          readonly = true
        }
      
        mount {
          type = "bind"
          target = "/var/opt/gitlab/config/templates"
          source = "local/workhorse/"
          readonly = false
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=workhorse"
          }
        }
      }

      resources {
        cpu = 256
        memory = 512
        memory_max = 512
      }

      env {
        CONFIG_TEMPLATE_DIRECTORY = "/var/opt/gitlab/config/templates"

        CONFIG_DIRECTORY = "/srv/gitlab/config"

        GITLAB_WORKHORSE_LISTEN_PORT = "8080"

        GITLAB_WORKHORSE_EXTRA_ARGS = "-authBackend http://http.webservice.gitlab.service.dc1.kjdev:8080 -cableBackend http://http.webservice.gitlab.service.dc1.kjdev:8080"
      }

      template {
        data = <<EOF
${WorkHorse.Config}
EOF

        destination = "local/workhorse/workhorse-config.toml"
      }

      template {
        data = <<EOF
6fad933c6267760415116fc4f35d2c7fc969f4ce0c162b49c3dd7be5517283e63000340ba7282dd97c2b3518b6d3c97a7cdd995dcb6f00dff11cf0aa316a459f
EOF

        destination = "secrets/workhorse/.gitlab_workhorse_secret"

        change_mode = "noop"
      }
    }
  }

}