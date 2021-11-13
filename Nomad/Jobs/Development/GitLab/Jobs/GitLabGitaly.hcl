job "gitlab-gitaly" {
  datacenters = ["core0site1"]

  #
  # GitLab Gitaly
  #
  group "gitlab-gitaly" {
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

      task = "gitlab-gitaly-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.gitaly"]
    }

    task "gitlab-gitaly-server" {
      driver = "docker"

      config {
        image = "${Image.Repo}/gitaly:${Image.Tag}"

        mount {
          type = "tmpfs"
          target = "/app/tmp"
          readonly = false
          tmpfs_options = {
            size = 100000
          }
        }
      }

      env {
        CONFIG_TEMPLATE_DIRECTORY = "/local/gitaly"
      }

      resources {
        cpu = 256
        memory = 512
        memory_max = 512
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
    }
  }
}