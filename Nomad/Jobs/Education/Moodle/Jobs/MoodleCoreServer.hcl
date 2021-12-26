job "education-moodle-coreserver" {
  datacenters = ["core0site1"]

  group "moodle-core-server" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" { 
        to = 8443
      }
    }

    service {
      name = "moodle"
      port = "http"

      task = "moodle-core-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.core"]
    }

    task "moodle-core-server" {
      driver = "docker"

      config {
        image = "erseco/alpine-moodle:latest"
      }

      resources {
        cpu = 512
        memory = 812
        memory_max = 2048
      }

      env {
        DB_TYPE = "pgsql"

        DB_PREFIX="mdl_"
      }

      template {
        data = <<EOH
#
# Database
#
DB_HOST="${Moodle.Database.Hostname}"
DB_PORT="${Moodle.Database.Port}"

DB_NAME="${Moodle.Database.Database}"
DB_USER="${Moodle.Database.Username}"
DB_PASS="${Moodle.Database.Password}"


EOH

        destination = "secrets/file.env"
        env = true
      }
    }
  }
}