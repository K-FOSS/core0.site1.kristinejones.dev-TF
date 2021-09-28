job "mattermost" {
  datacenters = ["core0site1"]

  group "mattermost-leader" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 8080
      }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "mattermost-leader-http-cont"
      port = "http"

      task = "mattermost-server"

      address_mode = "alloc"
    }

    task "mattermost-server" {
      driver = "docker"

      user = "101"

      config {
        image = "mattermost/mattermost-team-edition:${Version}"

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }
    
      env {
        RUN_SERVER_IN_BACKGROUND = "false"
        MM_SQLSETTINGS_DRIVERNAME = "postgres"
        MM_CLUSTERSETTINGS_ENABLE = "true"
        MM_NO_DOCKER = "true"
        MM_CLUSTERSETTINGS_CLUSTERNAME = "kjdev"

        APP_PORT_NUMBER = "8080"
      }

      template {
        data = <<EOH
#
# Database
#
MM_SQLSETTINGS_DATASOURCE="postgres://${Database.Username}:${Database.Password}@${Database.Hostname}/${Database.Database}?sslmode=disable&connect_timeout=10"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }

  group "mattermost-follower" {
    count = 3

    network {
      mode = "cni/nomadcore1"

      port "http" { }

      dns {
        servers = ["172.16.0.1", "172.16.0.2", "172.16.0.126"]
      }
    }

    service {
      name = "mattermost-follower-http-cont"
      port = "http"

      task = "mattermost-follower"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      address_mode = "alloc"
    }

    task "mattermost-follower" {
      driver = "docker"

      user = "101"

      config {
        image = "mattermost/mattermost-team-edition:${Version}"

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }
    
      env {
        RUN_SERVER_IN_BACKGROUND = "false"
        MM_SQLSETTINGS_DRIVERNAME = "postgres"
        MM_CLUSTERSETTINGS_ENABLE = "true"
        MM_NO_DOCKER = "true"
        MM_CLUSTERSETTINGS_CLUSTERNAME = "kjdev"

        APP_PORT_NUMBER = "$${NOMAD_PORT_http}"
      }

      template {
        data = <<EOH
#
# Database
#
MM_SQLSETTINGS_DATASOURCE="postgres://${Database.Username}:${Database.Password}@${Database.Hostname}:${Database.Port}/${Database.Database}?sslmode=disable&connect_timeout=10"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }
}