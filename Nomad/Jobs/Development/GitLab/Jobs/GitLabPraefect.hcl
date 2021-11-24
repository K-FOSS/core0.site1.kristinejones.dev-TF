job "gitlab-praefect" {
  datacenters = ["core0site1"]

  #
  # GitLab Gitaly
  #
  group "gitlab-praefect" {
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

      task = "gitlab-praefect-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.praefect"]
    }

    task "gitlab-praefect-server" {
      driver = "docker"

      config {
        image = "${Image.Repo}/praefect:${Image.Tag}"

        mount {
          type = "bind"
          target = "/etc/gitaly/.gitlab_shell_secret"
          source = "secrets/shell/.gitlab_shell_secret"
          readonly = true
        }

        mount {
          type = "tmpfs"
          target = "/app/tmp"
          readonly = false
          tmpfs_options = {
            size = 100000
          }
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=gitaly"
          }
        }
      }

      env {
        CONFIG_TEMPLATE_DIRECTORY = "/local/gitaly"
      }

      resources {
        cpu = 100
        memory = 256
        memory_max = 256
      }

      template {
        data = <<EOF
${Gitaly.GitConfig}
EOF

        destination = "local/Loki.yaml"
      }

      template {
        data = <<EOF
${Gitaly.Config}
EOF

        destination = "local/gitaly/config.toml"
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