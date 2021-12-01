job "business-vikunja-api" {
  datacenters = ["core0site1"]

  group "vikunja" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 3456
      }
    }

    service {
      name = "vikunja"
      port = "https"

      task = "vikunja-api-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.api"]
    }

    task "vikunja-api-server" {
      driver = "docker"

      config {
        image = "vikunja/api"
      }

      env {
        #
        # Database
        #
        VIKUNJA_DATABASE_TYPE = "postgres"

        VIKUNJA_DATABASE_HOST = "${Database.Hostname}:${Database.Port}"
        VIKUNJA_DATABASE_DATABASE = "${Database.Database}"

        VIKUNJA_DATABASE_USER = "${Database.Username}"
        VIKUNJA_DATABASE_PASSWORD = "${Database.Password}"
      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 128
      }
    }
  }
}