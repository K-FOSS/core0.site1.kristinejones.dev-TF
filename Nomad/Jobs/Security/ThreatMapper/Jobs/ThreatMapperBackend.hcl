job "security-threatmapper-backend" {
  datacenters = ["core0site1"]

  group "threatmapper-backend-server" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" { 
        to = 4041
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

      task = "threatmapper-backend-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.backend"]

      meta {
        meta = "for your service"
      }
    }

    task "threatmapper-backend-server" {
      driver = "docker"

      config {
        image = "${ThreatMapper.Image.Repo}/deepfence_api_ce:${ThreatMapper.Image.Tag}"

        entrypoint = ["/app/code/dockerify/backend/entrypoint.sh"]

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=threatmapper,service=backend"
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
        # PostgreSQL
        #

        #
        # PSQL Fetcher
        #

        POSTGRES_FETCHER_DB_HOST = "${Database.Fetcher.Hostname}"
        POSTGRES_FETCHER_DB_PORT = "${Database.Fetcher.Port}"

        POSTGRES_FETCHER_DB_SSLMODE = "disabled"

        POSTGRES_FETCHER_DB_NAME = "${Database.Fetcher.Database}"

        POSTGRES_FETCHER_DB_USER = "${Database.Fetcher.Username}"
        POSTGRES_FETCHER_DB_PASSWORD = "${Database.Fetcher.Password}"



        #
        # PSQL User
        #

        POSTGRES_USER_DB_HOST = "${Database.User.Hostname}"
        POSTGRES_USER_DB_PORT = "${Database.User.Port}"

        POSTGRES_USER_DB_SSLMODE = "disabled"

        POSTGRES_USER_DB_NAME = "${Database.User.Database}"


        POSTGRES_USER_DB_USER = "${Database.User.Username}"
        POSTGRES_USER_DB_PASSWORD = "${Database.User.Password}"

        #
        # ElasticSearch
        #
        ELASTICSEARCH_HOST = "https.master.opensearch.service.kjdev"
        ELASTICSEARCH_PORT = "9200"

        #
        # Redis
        #
        REDIS_HOST = "redis.threatmapper.service.kjdev"
        REDIS_PORT = "6379"
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
        memory_max = 1024
      }
    }
  }
}