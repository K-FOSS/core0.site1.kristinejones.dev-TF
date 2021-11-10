job "mattermost" {
  datacenters = ["core0site1"]

  group "mattermost-leader" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 8080
      }
    }

    service {
      name = "mattermost-leader-http-cont"
      port = "http"

      task = "mattermost-server"
      address_mode = "alloc"

      tags = ["coredns.enabled"]
    }

    task "mattermost-server" {
      driver = "docker"

      user = "101"

      config {
        image = "mattermost/mattermost-team-edition:${Version}"

        args = ["mattermost", "server", "-c", "/local/config.json"]
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
MM_SQLSETTINGS_DATASOURCE="postgres://${Database.Username}:${Database.Password}@${Database.Hostname}:${Database.Port}/${Database.Database}?sslmode=disable&connect_timeout=10"
DB_HOST="${Database.Hostname}"
DB_PORT_NUMBER="${Database.Port}"
EOH

        destination = "secrets/file.env"
        env         = true
      }
    }
  }
}