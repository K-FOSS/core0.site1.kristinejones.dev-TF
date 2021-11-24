job "development-gitlab-pages" {
  datacenters = ["core0site1"]

  #
  # GitLab Pages
  #
  group "gitlab-pages" {
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

      task = "gitlab-pages-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.pages"]
    }

    task "gitlab-pages-server" {
      driver = "docker"

      config {
        image = "${Image.Repo}/gitlab-pages:${Image.Tag}"

        mount {
          type = "tmpfs"
          target = "/local/pages"
          readonly = false
          tmpfs_options = {
            size = 100000
          }
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=pages"
          }
        }
      }

      resources {
        cpu = 256
        memory = 512
        memory_max = 512
      }

      env {
        CONFIG_TEMPLATE_DIRECTORY = "/local/pages/templates"

        CONFIG_DIRECTORY = "/local/pages/config"

        PAGES_CONFIG_FILE = "/local/pages/pages-config"
      }

      template {
        data = <<EOF
${Pages.Config}
EOF

        destination = "local/pages/templates/pages-config.erb"
      }
    }
  }
}