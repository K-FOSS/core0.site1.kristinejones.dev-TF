job "gitlab" {
  datacenters = ["core0site1"]

  group "gitlab-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "gitlab"
      port = "redis"

      task = "gitlab-redis-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]

      check {
        name = "tcp_validate"

        type = "tcp"

        port = "redis"
        address_mode = "alloc"

        initial_status = "passing"

        interval = "30s"
        timeout  = "10s"

        check_restart {
          limit = 6
          grace = "120s"
          ignore_warnings = true
        }
      }
    }

    task "gitlab-redis-server" {
      driver = "docker"

      config {
        image = "redis:latest"
      }
    }
  }

  #
  # HTTP/HTTPS/TLS/TCP/UDP/HTTP3 Load Balacner/Comrpession
  #

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

  #
  # GitLab Migrations
  #
  group "gitlab-migrations" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"
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
    }

    task "gitlab-migrations-task" {
      driver = "docker"

      lifecycle {
        hook = "poststart"
        sidecar = false
      }

      config {
        image = "${Image.Repo}/gitlab-rails-ce:${Image.Tag}"

        command = "/scripts/db-migrate"
      }

      resources {
        cpu = 128
        memory = 512
        memory_max = 512
      }

      template {
        data = <<EOF
${WebService.Templates.Cable}
EOF

        destination = "local/webservice/configtemplates/cable.yaml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.Database}
EOF

        destination = "local/webservice/configtemplates/database.yaml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.GitlabRB}
EOF

        destination = "local/webservice/configtemplates/gitlab.yml.erb"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.Resque}
EOF

        destination = "local/webservice/configtemplates/resque.yaml"

        change_mode = "noop"
      }
    }
  }

 #
  # GitLab Web Service
  #
  group "gitlab-webservice" {
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
    }

    service {
      name = "gitlab"
      port = "http"

      task = "gitlab-webservice-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.webservice"]
    }

    task "gitlab-webservice-server" {
      driver = "docker"

      config {
        image = "${Image.Repo}/gitlab-webservice-ce:${Image.Tag}"
      }

      resources {
        cpu = 256
        memory = 512
        memory_max = 512
      }

      env {
        #
        # 
        #
        GITLAB_WEBSERVER = "PUMA"

        INTERNAL_PORT = "8080"


        #
        # Configs
        #
        CONFIG_TEMPLATE_DIRECTORY = "/local/webservice/configtemplates"
        CONFIG_DIRECTORY = "/local/webservice/config"
      }

      template {
        data = <<EOF
${WebService.Templates.Cable}
EOF

        destination = "local/webservice/configtemplates/cable.yaml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.Database}
EOF

        destination = "local/webservice/configtemplates/database.yaml"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.GitlabRB}
EOF

        destination = "local/webservice/configtemplates/gitlab.yml.erb"

        change_mode = "noop"
      }

      template {
        data = <<EOF
${WebService.Templates.Resque}
EOF

        destination = "local/webservice/configtemplates/resque.yaml"

        change_mode = "noop"
      }
    }
  }

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

      port "http" { 
        to = 8080
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
    }

    task "wait-for-gitlab-webservice" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z http.webservice.gitlab.service.dc1.kjdev 6379; do sleep 1; done"]
      }
    }

    service {
      name = "gitlab"
      port = "http"

      task = "gitlab-workhorse-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.workhorse"]
    }

    task "gitlab-workhorse-server" {
      driver = "docker"

      config {
        image = "${Image.Repo}/gitlab-workhorse-ce:${Image.Tag}"

        command = "/scripts/start-workhorse"
      }

      resources {
        cpu = 256
        memory = 512
        memory_max = 512
      }

      env {
        CONFIG_TEMPLATE_DIRECTORY = "/local/workhorse/templates"

        CONFIG_DIRECTORY = "/local/workhorse/config"

        GITLAB_WORKHORSE_LISTEN_PORT = "8080"
      }

      template {
        data = <<EOF
${WorkHorse.Config}
EOF

        destination = "local/workhorse/workhorse-config.toml"
      }
    }
  }
}