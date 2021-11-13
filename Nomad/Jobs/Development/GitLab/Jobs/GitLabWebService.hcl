job "development-gitlab-webservice" {
  datacenters = ["core0site1"]

 #
  # GitLab Web Service
  #
  group "gitlab-webservice" {
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

        mount {
          type = "tmpfs"
          target = "/srv/gitlab/config"
          readonly = false
          tmpfs_options = {
            size = 100000
          }
        }

        mount {
          type = "bind"
          target = "/var/opt/gitlab/templates"
          source = "local/webservice/configtemplates"
          readonly = true
          bind_options {
            propagation = "rshared"
          }
        }

      }

      resources {
        cpu = 256
        memory = 512
        memory_max = 512
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
        CONFIG_TEMPLATE_DIRECTORY = "/var/opt/gitlab/templates"
        CONFIG_DIRECTORY = "/srv/gitlab/config"
      }

      template {
        data = <<EOF
${WebService.EntryScript}
EOF

        destination = "local/entry.sh"

        perms = "777"
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
    }
  }

}