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
    }

    service {
      name = "gitlab"
      port = "api"

      task = "gitlab-toolbox"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.api.kas"]
    }

    task "gitlab-toolbox" {
      driver = "docker"

      config {
        image = "${Image.Repo}/gitlab-toolbox-ce:${Image.Tag}"

        args = ["--configuration-file=/local/Config.yaml"]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=toolbox"
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
        # Config
        #


        #
        # Misc
        #
        GITLAB_HOST = "https://gitlab.kristianjones.dev"
        GITLAB_PORT = "443"

        #
        # Rails
        #
        ENABLE_BOOTSNAP = "1"


      }

      #
      # Configs
      #
      
      #
      # GitLab YAML
      #
      template {
        data = <<EOF
${GitLab.Configs.GitLab}
EOF

        destination = "local/configtemplates/gitlab.yml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${GitLab.Configs.Cable}
EOF

        destination = "local/configtemplates/cable.yml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${GitLab.Configs.Database}
EOF

        destination = "local/configtemplates/database.yml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${GitLab.Configs.Resque}
EOF

        destination = "local/configtemplates/resque.yml"

        change_mode = "noop"
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