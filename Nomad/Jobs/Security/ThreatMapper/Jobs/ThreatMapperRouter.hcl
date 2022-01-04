job "security-threatmapper-router" {
  datacenters = ["core0site1"]

  group "threatmapper-router-server" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 80
      }

      port "https" { 
        to = 443
      }

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    task "wait-for-threatmapper-redis" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z redis.threatmapper.service.kjdev 6379; do sleep 1; done"]
      }

      resources {
        cpu = 16
        memory = 16
      }
    }

    service {
      name = "threatmapper"
      port = "https"

      task = "threatmapper-router-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.router"]

      meta {
        meta = "for your service"
      }
    }

    service {
      name = "threatmapper"
      port = "http"

      task = "threatmapper-router-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http.router"]

      meta {
        meta = "for your service"
      }
    }

    task "threatmapper-ui-server" {
      driver = "docker"

      config {
        image = "${ThreatMapper.Image.Repo}/deepfence_router_ce:${ThreatMapper.Image.Tag}"

        memory_hard_limit = 512

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=threatmapper,service=ui"
          }
        }
      }

      env {
        #
        # TODO
        #
        ANALYZER_REPLICATION_FACTOR = "1"

        ANALYZER_SERVICE_NAME_PREFIX = "deepfence-analyzer-"

        mapper_image_name = ""
        image_tag = ""

        router_service = "https.router.threatmapper.service.kjdev:443"
        VULNERABILITY_SCAN_CONCURRENCY = "10"


        #
        # PSQL User
        #

        POSTGRES_USER_DB_HOST = "${ThreatMapper.Database.User.Hostname}"
        POSTGRES_USER_DB_PORT = "${ThreatMapper.Database.User.Port}"

        POSTGRES_USER_DB_SSLMODE = "disable"

        POSTGRES_USER_DB_NAME = "${ThreatMapper.Database.User.Database}"


        POSTGRES_USER_DB_USER = "${ThreatMapper.Database.User.Username}"
        POSTGRES_USER_DB_PASSWORD = "${ThreatMapper.Database.User.Password}"
      }

      template {
        data = <<EOH

EOH

        destination = "secrets/file.env"
        env = true
      }

      resources {
        cpu = 128

        memory = 256
        memory_max = 512
      }
    }
  }
}