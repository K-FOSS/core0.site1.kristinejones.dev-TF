job "development-gitlab-kas" {
  datacenters = ["core0site1"]


  #
  # GitLab Kubernetes Agent Server
  #
  group "gitlab-kas" {
    count = 3

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

      port "kas" { 
        to = 8155
      }

      port "kube" { 
        to = 8154
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

    service {
      name = "gitlab"
      port = "kas"

      task = "gitlab-kas-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.kas.kas"]
    }

    service {
      name = "gitlab"
      port = "kube"

      task = "gitlab-kas-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.kube.kas"]
    }

    task "gitlab-kas-server" {
      driver = "docker"

      config {
        image = "${Image.Repo}/kas:${Image.Tag}"

        args = ["--configuration-file=/local/Config.yaml"]

        memory_hard_limit = 256

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=kas"
          }
        }
      }

      resources {
        cpu = 64

        memory = 64
        memory_max = 256
      }

      env {

        #
        # Misc
        #
        GITLAB_HOST = "https://gitlab.kristianjones.dev"
        GITLAB_PORT = "443"
        
        OWN_PRIVATE_API_URL = "grpc://http.kas.kas.gitlab.service.dc1.kjdev:8155"
      }

      template {
        data = <<EOF
${KAS.Config}
EOF

        destination = "local/Config.yaml"
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