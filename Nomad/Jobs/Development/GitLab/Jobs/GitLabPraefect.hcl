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

      port "metrics" { 
        to = 9000
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
        image = "${Image.Repo}/gitaly:${Image.Tag}"

        #
        # TODO: Fine tune this?
        #
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

            loki-external-labels = "job=gitlab,service=praefect"
          }
        }
      }

      env {
        PRAEFECT_CONFIG_FILE = "/local/Config.toml"

        USE_PRAEFECT_SERVICE = "1"
        PRAEFECT_AUTO_MIGRATE = "1"
      }

      resources {
        cpu = 100
        memory = 256
        memory_max = 256
      }

      template {
        data = <<EOF
${Praefect.Config}
EOF

        destination = "local/Config.toml"
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