terraform {
  required_providers {
    #
    # Hashicorp Vault
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    #
    nomad = {
      source = "hashicorp/nomad"
      version = "1.4.15"
    }

    #
    # GitHub Provider
    #
    # Used to fetch the latest PSQL file
    #
    # Docs: https://registry.terraform.io/providers/integrations/github/latest
    #
    github = {
      source = "integrations/github"
      version = "4.17.0"
    }

    #
    # Hashicorp Terraform HTTP Provider
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/http/latest/docs
    #
    http = {
      source = "hashicorp/http"
      version = "2.1.0"
    }

    #
    # Randomness
    #
    # TODO: Find a way to best improve true randomness?
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/random/latest/docs
    #
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

resource "nomad_job" "GitLabJob" {
  jobspec = templatefile("${path.module}/Jobs/GitLab.hcl", {
    Image = {
      Repo = "registry.gitlab.com/gitlab-org/build/cng"

      Tag = "master"
    }

    Gitaly = {
      GitConfig = templatefile("${path.module}/Configs/Gitaly/gitconfig", {
      })

      Config = templatefile("${path.module}/Configs/Gitaly/config.toml", {
      })
    }

    Pages = {
      Config = templatefile("${path.module}/Configs/Pages/Pages-config.erb", {
      })
    }

    WebService = {
      Templates = {
        Cable = templatefile("${path.module}/Configs/WebService/Cable.yaml", {

        })

        Database = templatefile("${path.module}/Configs/WebService/Database.yaml", {
          Database = var.Database
        })

        GitlabRB = templatefile("${path.module}/Configs/WebService/Gitlab.yml.erb", {
        })

        Resque = templatefile("${path.module}/Configs/WebService/Resque.yaml", {
        })

      }
    }

    Shell = {
      Config = templatefile("${path.module}/Configs/Shell/Config.yml.erb", {
      })
    }

    Sidekiq = {
      Templates = {
        Database = templatefile("${path.module}/Configs/Sidekiq/Database.yaml", {
          Database = var.Database
        })

        GitlabYAML = templatefile("${path.module}/Configs/Sidekiq/Gitlab.yaml", {
        })

        Resque = templatefile("${path.module}/Configs/Sidekiq/Resque.yaml", {
        })

        SidekiqQueues = templatefile("${path.module}/Configs/Sidekiq/SidekiqQueues.yaml", {
        })
      }
    }

    WorkHorse = {
      Config = templatefile("${path.module}/Configs/WorkHorse/WorkhorseConfig.toml", {
      })
    }
    
    #
    # TODO: Change back to split("v", data.github_release.Release.release_tag)[1] once https://github.com/grafana/grafana/pull/37765 is released on prod
    #
    Version = "main"
  })
}