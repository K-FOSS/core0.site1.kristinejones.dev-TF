job "development-gitlab-webservice" {
  datacenters = ["core0site1"]

 #
  # GitLab Web Service
  #
  group "gitlab-webservice" {
    count = 2

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

    service {
      name = "gitlab"
      port = "https"

      task = "gitlab-webservice-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.webservice"]

      #
      # Liveness check
      #
      check {
        name = "HTTP Check"
        type = "http"

        address_mode = "alloc"
        port = "https"

        path = "/-/liveness"
        interval = "10s"
        timeout  = "3s"

        check_restart {
          limit = 12
          grace = "60s"
          ignore_warnings = false
        }
      }

      #
      # Readiness
      #
      check {
        name = "HTTP Check"
        type = "http"

        address_mode = "alloc"
        port = "https"

        path = "/-/readiness"
        interval = "10s"
        timeout  = "3s"

        check_restart {
          limit = 12
          grace = "60s"
          ignore_warnings = false
        }
      }
    }

    task "gitlab-webservice-server" {
      driver = "docker"

      user = "root"

      config {
        image = "${Image.Repo}/gitlab-webservice-ce:${Image.Tag}"

        entrypoint = ["/local/Entry.sh"]
        args = []

        mount {
          type = "bind"
          target = "/opt/gitlab/embedded/ssl/certs/gitlab.pem"
          source = "secrets/TLS/CA.pem"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/opt/gitlab/embedded/ssl/certs/registry.pem"
          source = "local/TLS/RegistryCA.pem"
          readonly = false
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=gitlab,service=webservice"
          }
        }
      }

      resources {
        cpu = 812
        memory = 4096
        memory_max = 4096
      }

      env {
        #
        # 
        #
        GITLAB_WEBSERVER = "PUMA"

        INTERNAL_PORT = "443"

        prometheus_multiproc_dir = "/tmp"


        #
        # Configs
        #
        CONFIG_TEMPLATE_DIRECTORY = "/local/configtemplates"
        CONFIG_DIRECTORY = "/srv/gitlab/config"

        EXTERNAL_URL = "https://gitlab.kristianjones.dev"

        GITLAB_HOST = "https://gitlab.kristianjones.dev"
        GITLAB_PORT = "443"
        GITLAB_SSH_PORT = "2222"

        GITALY_FEATURE_DEFAULT_ON = "1"

        ACTION_CABLE_IN_APP = "true"

        REGISTRY_PORT = "5000"

        WAIT_FOR_TIMEOUT = "60"

        GITLAB_ROOT_PASSWORD = "RANDOM_PASS5859!!"

        ENABLE_BOOTSNAP = "1"

        #
        # Puma
        #
        PUMA_WORKER_MAX_MEMORY = "2048"

        GITLAB_TRACING = "opentracing://jaeger?http_endpoint=http%3A%2F%2Fhttp.distributor.tempo.service.kjdev%3A14268%2Fapi%2Ftraces&sampler=const&sampler_param=1"

        #
        # TLS
        #SSL_CERT_FILE
      }

      #
      # Configs
      #

      template {
        data = <<EOF
${WebService.EntryScript}
EOF

        destination = "local/Entry.sh"

        change_mode = "noop"
      }
      
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
      # Secrets YAML
      #
      template {
        data = <<EOF
production:
  secret_key_base: ${Secrets.SecretKeyBase}
  db_key_base: ${Secrets.DatabaseKeyBase}
  otp_key_base: ${Secrets.OTPKeyBase}
  encrypted_settings_key_base: ${Secrets.DatabaseKeyBase}
  openid_connect_signing_key: |
    ${Secrets.OpenIDSigningKey}
  ci_jwt_signing_key: |
    ${Secrets.OpenIDSigningKey}
EOF

        destination = "local/configtemplates/secrets.yml"

        change_mode = "noop"
      }

      #
      # TLS
      #

      #
      # Registry
      #

      template {
        data = <<EOF
${TLS.Registry.CA}
EOF

        destination = "local/TLS/RegistryCA.pem"

        change_mode = "noop"
      }
    
      template {
        data = <<EOF
${TLS.Registry.Cert}
EOF

        destination = "secrets/TLS/Registry.pem"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${TLS.Registry.Key}
EOF
        destination = "secrets/TLS/Registry.key"

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

      template {
        data = <<EOF
${WebService.TLS.CA}
EOF

        destination = "secrets/TLS/CA.pem"
      }

      template {
        data = <<EOF
${WebService.TLS.Cert}
EOF

        destination = "secrets/TLS/Cert.pem"
      }

      template {
        data = <<EOF
${WebService.TLS.Key}
EOF

        destination = "secrets/TLS/Cert.key"
      }
    }
  }

}