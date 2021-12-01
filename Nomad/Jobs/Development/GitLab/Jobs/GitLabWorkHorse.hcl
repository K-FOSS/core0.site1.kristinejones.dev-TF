job "development-gitlab-workhorse" {
  datacenters = ["core0site1"]

  #
  # GitLab WorkHorse
  #
  group "gitlab-workhorse" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" { 
        to = 443
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

      resources {
        cpu = 16
        memory = 16
      }
    }

    task "wait-for-gitlab-webservice" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z https.webservice.gitlab.service.dc1.kjdev 443; do sleep 1; done"]
      }

      resources {
        cpu = 16
        memory = 16
      }
    }

    service {
      name = "gitlab"
      port = "https"

      task = "gitlab-workhorse-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.workhorse"]
    }

    task "gitlab-workhorse-server" {
      driver = "docker"

      config {
        image = "${Image.Repo}/gitlab-workhorse-ce:${Image.Tag}"

        command = "/scripts/start-workhorse"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=workhorse"
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
        # Configs
        #
        CONFIG_TEMPLATE_DIRECTORY = "/local/configtemplates"

        CONFIG_DIRECTORY = "/srv/gitlab/config"

        #
        # Workhorse
        #
        GITLAB_WORKHORSE_LISTEN_PORT = "443"
        GITLAB_WORKHORSE_EXTRA_ARGS = "-authBackend http://https.webservice.gitlab.service.dc1.kjdev:443 -cableBackend http://https.webservice.gitlab.service.dc1.kjdev:443"

        ENABLE_BOOTSNAP = "1"

        #
        # Misc - External Access
        #
        GITLAB_HOST = "https://gitlab.kristianjones.dev"
        GITLAB_PORT = "443"

        #
        # Tracing
        #
        GITLAB_TRACING = "opentracing://jaeger?http_endpoint=http%3A%2F%2Fhttp.distributor.tempo.service.kjdev%3A14268%2Fapi%2Ftraces&sampler=const&sampler_param=1"
      }

      template {
        data = <<EOF
${WorkHorse.Config}
EOF

        destination = "local/configtemplates/workhorse-config.toml"
      }

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
      # TLS
      #

      #
      # Server
      #


      template {
        data = <<EOF
${WorkHorse.TLS.CA}
EOF

        destination = "secrets/TLS/CA.pem"
      }

      template {
        data = <<EOF
${WorkHorse.TLS.Cert}
EOF

        destination = "secrets/TLS/Cert.pem"
      }

      template {
        data = <<EOF
${WorkHorse.TLS.Key}
EOF

        destination = "secrets/TLS/Cert.key"
      }

      #
      # mTLS
      #

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