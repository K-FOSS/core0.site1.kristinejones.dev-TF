job "backups-psql-wal-g" {
  datacenters = ["core0site1"]

  type = "batch"

  periodic {
    cron = "*/15 * * * * *"
    prohibit_overlap = true
    time_zone = "America/Winnipeg"
  }

  group "consul-backup" {
    count = 1

    network {
      mode = "cni/nomadcore1"
    }

    task "psql-wal-g" {
      driver = "docker"

      config {
        image = "bitnami/wal-g:1.1.0"

        tty = true
        args = ["backup-push", "--pgpassfile=/secrets/.pgpass"]
      }

      env {
        PGPASSFILE = "/secrets/.pgpass"

        #
        # S3
        #
        AWS_S3_FORCE_PATH_STYLE = "true"
        AWS_REGION = "us-east-1"

        PGHOST = "${WalG.Database.Hostname}"
        PG_HOST = "${WalG.Database.Hostname}"
        PGPORT = "${WalG.Database.Port}"
        PGUSER = "${WalG.Database.Username}"
        PG_USER = "${WalG.Database.Username}"
      }

      #
      # Secrets
      #

      template {
        data = <<EOH
${WalG.Database.Hostname}:${WalG.Database.Port}:*:${WalG.Database.Username}:${WalG.Database.Password}
EOH

        perms = "600"

        destination = "secrets/.pgpass"
      }


      template {
        data = <<EOH
#
# S3
#
AWS_ACCESS_KEY_ID="${WalG.S3.Credentials.AccessKey}"
AWS_SECRET_ACCESS_KEY="${WalG.S3.Credentials.SecretKey}"
AWS_ENDPOINT="http${WalG.S3.Connection.Endpoint}"
WALG_S3_PREFIX="s3://${WalG.S3.Bucket}/wal-g"
EOH

        destination = "secrets/file.env"
        env = true
      }

      resources {
        cpu = 64
        memory = 64
        memory_max = 128
      }
    }
  }
}