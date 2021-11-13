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
    }
  }

}