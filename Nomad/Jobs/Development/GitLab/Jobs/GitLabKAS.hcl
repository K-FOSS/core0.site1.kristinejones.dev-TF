job "development-gitlab-kas" {
  datacenters = ["core0site1"]


  #
  # GitLab Kubernetes Agent Server
  #
  group "gitlab-kas" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "api" { 
        to = 8080
      }

      port "agent" { 
        to = 8085
      }
    }

    service {
      name = "gitlab"
      port = "api"

      task = "gitlab-kas-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.api.kas"]
    }

    service {
      name = "gitlab"
      port = "agent"

      task = "gitlab-kas-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.agent.kas"]
    }

    task "gitlab-kas-server" {
      driver = "docker"

      config {
        image = "${Image.Repo}/kas:${Image.Tag}"

        args = ["--configuration-file=/local/Config.yaml"]

        mount {
          type = "bind"
          target = "/srv/gitlab-secrets/.gitlab_shell_secret"
          source = "secrets/shell/.gitlab_shell_secret"
          readonly = true
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=kas"
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
        # Misc
        #
        GITLAB_HOST = "https://gitlab.kristianjones.dev"
        GITLAB_PORT = "443"
        
        OWN_PRIVATE_API_URL = "grpc://http.kas.gitlab.service.dc1.kjdev:"
      }

      template {
        data = <<EOF
${KAS.Config}
EOF

        destination = "local/Config.yaml"
      }

      template {
        data = <<EOF
${Secrets.Shell}
EOF

        destination = "secrets/shell/.gitlab_shell_secret"

        change_mode = "noop"
      }

      template {
        data = "${Secrets.WorkHorse}"

        destination = "secrets/workhorse/.gitlab_workhorse_secret"

        change_mode = "noop"
      }

      template {
        data = "${Secrets.KAS}"

        destination = "secrets/KAS/.gitlab_kas_secret"

        change_mode = "noop"
      }
    }
  }

}