job "development-gitlab-shell" {
  datacenters = ["core0site1"]


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
    }

    task "gitlab-shell-server" {
      driver = "docker"

      config {
        image = "${Image.Repo}/gitlab-shell:${Image.Tag}"

        mount {
          type = "bind"
          target = "/srv/gitlab-secrets/.gitlab_shell_secret"
          source = "secrets/shell/.gitlab_shell_secret"
          readonly = true
        }

        mount {
          type = "tmpfs"
          target = "/local/gitlab-shell"
          readonly = false
          tmpfs_options = {
            size = 100000
          }
        }
      }

      resources {
        cpu = 256
        memory = 512
        memory_max = 512
      }

      env {
        CONFIG_TEMPLATE_DIRECTORY = "/local/gitlab-config"

        CONFIG_DIRECTORY = "/local/gitlab-shell"
      }

      template {
        data = <<EOF
${Shell.Config}
EOF

        destination = "local/gitlab-config/config.yaml.erb"
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